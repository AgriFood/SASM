library(readxl)
library(dplyr)
library(purrr)
library(openxlsx)
library(tidyr)

# Sammanställer resultaten från histosol-scenarierna till en Excel-fil.
# Körs från modellens rotkatalog (den mapp där SASM2025.gms ligger), t.ex.
#   setwd("C:/Users/celn0004/Documents/Modellering/SASM/Github/SASM_scen-histosol")
#   source("analysis/histosol_resultat.R")
rot <- getwd()
if (!file.exists(file.path(rot, "SASM2025.gms"))) {
  stop("Kör skriptet från modellens rotkatalog (där SASM2025.gms ligger). Nu: ", rot)
}

source(file.path(rot, "analysis", "kategorier.R"))

# --- Konfigurera horisont och scenarier ---
# horisont = resultatmappen under output, samma som resultFolder i settings.gms
horisont <- "histosol_2030"

scenarier <- c(
  "baseline",
  "rewet",
  "rewet_opt",
  "convert",
  "convert_opt",
  "rewet_convert",
  "rewet_convert_opt"
)

dir_output <- file.path(rot, "output", horisont)
dir_analys <- file.path(dir_output, "Analysis")
dir.create(dir_analys, recursive = TRUE, showWarnings = FALSE)

# --- Översätt GAMS-specialvärden och konvertera numeriska kolumner ---
gams_to_num <- function(x) {
  if (!is.character(x)) return(x)
  x2 <- x
  x2[x2 %in% c("Eps", "EPS", "eps")]   <- "0"   # epsilon ≈ 0
  x2[x2 %in% c("Undf", "UNDF", "NA")]  <- NA     # odefinierat
  suppressWarnings(num <- as.numeric(x2))
  # Om alla icke-tomma värden gick att tolka som tal -> gör kolumnen numerisk
  if (all(is.na(num) == is.na(x2))) num else x
}

# --- Hjälpfunktion: läs och jämför en flik (valfritt range) ---
jamfor_flik <- function(flik, range = NULL) {
  
  data_lista <- lapply(scenarier, function(s) {
    fil <- file.path(dir_output, paste0(s, ".xlsx"))
    df <- read_xlsx(fil, sheet = flik, range = range, col_names = TRUE)
    names(df) <- ifelse(grepl("^\\.\\.\\.\\d+$", names(df)),
                        paste0("col_", seq_along(names(df))),
                        names(df))
    # Konvertera tomma kolumner + GAMS-specialvärden till numeriska
    df <- df %>%
      mutate(across(where(is.logical), as.numeric)) %>%
      mutate(across(where(is.character), gams_to_num))
    df
  })
  names(data_lista) <- scenarier
  
  ref <- data_lista[[1]]
  index_kol <- names(ref)[sapply(ref, is.character)]
  varde_kol <- setdiff(names(ref), index_kol)
  
  if (length(varde_kol) <= 1) {
    # --- Brett format: en kolumn per scenario ---
    byt_namn <- function(df, scenarie) {
      names(df)[names(df) %in% varde_kol] <- scenarie
      df
    }
    result <- byt_namn(data_lista[[1]], scenarier[1])
    for (s in scenarier[-1]) {
      df_s <- byt_namn(data_lista[[s]], s)
      if (length(index_kol) > 0) {
        result <- full_join(result, df_s, by = index_kol)
      } else {
        result <- bind_cols(result, df_s)
      }
    }
  } else {
    # --- Långt format: extra dimensionskolumn + en kolumn per scenario ---
    lang_lista <- lapply(scenarier, function(s) {
      data_lista[[s]] %>%
        tidyr::pivot_longer(
          cols = all_of(varde_kol),
          names_to = "variabel",
          values_to = "varde"
        ) %>%
        mutate(scenarie = s)
    })
    result <- bind_rows(lang_lista) %>%
      tidyr::pivot_wider(
        names_from = scenarie,
        values_from = varde
      )
  }
  
  result
}

# --- Särskild hantering av Z (ett enda värde per scenario) ---
jamfor_z <- function() {
  z_varden <- sapply(scenarier, function(s) {
    fil <- file.path(dir_output, paste0(s, ".xlsx"))
    # Bladet har etiketten netSurplus överst och värdet sist
    df <- read_xlsx(fil, sheet = "Z", col_names = FALSE, .name_repair = "minimal")
    as.numeric(df[[ncol(df)]][nrow(df)])
  })
  data.frame(
    scenarie = scenarier,
    Z = z_varden
  )
}

# --- Kör och skriv direkt till workbook ---
wb <- createWorkbook()

# Z först
message("  Bearbetar: Z ", format(Sys.time(), "%H:%M:%S"))
addWorksheet(wb, "Z")
writeData(wb, "Z", jamfor_z())

# --- SR_inputs: markkategorier, ordnade och kompletta ---
sr_inputs_markkategorier <- function() {
  
  markkat <- c("CROPLAND", "PRMPAST", "PRMPASTT", "PRMPASTN",
               "PRMPASTH", "PRMPASTHT", "PRMPASTHN", "PRMALV", "PRMFOR",
               "PRMMOS", "PRMLOW", "PRMCHAL", "PRMMEAD")
  
  # Läs in och filtrera varje scenario
  data_lista <- lapply(scenarier, function(s) {
    fil <- file.path(dir_output, paste0(s, ".xlsx"))
    df <- read_xlsx(fil, sheet = "SR_inputs", col_names = TRUE)
    names(df)[1:3] <- c("R", "SR", "I")
    df %>%
      mutate(across(where(is.logical), as.numeric)) %>%
      mutate(across(where(is.character), gams_to_num)) %>%
      filter(I %in% markkat) %>%
      select(R, SR, I, USE, `FIXED-SUP`)
  })
  names(data_lista) <- scenarier
  
  # Komplett rutnät: alla (R, SR) × markkategorier, i ordning
  rutnat <- bind_rows(lapply(data_lista, function(d) distinct(d, R, SR))) %>%
    distinct() %>%
    arrange(SR) %>%
    tidyr::crossing(I = factor(markkat, levels = markkat)) %>%
    arrange(SR, I) %>%
    mutate(I = as.character(I))
  
  # Join in USE och FIXED-SUP per scenario
  result <- rutnat
  for (s in scenarier) {
    df_s <- data_lista[[s]] %>%
      select(SR, I, USE, `FIXED-SUP`) %>%
      rename(!!paste0("USE_", s)       := USE,
             !!paste0("FIXED-SUP_", s) := `FIXED-SUP`)
    result <- left_join(result, df_s, by = c("SR", "I"))
  }
  
  result
}

# --- Products, Activities, Inputs: med typ-kolumn ---
typade_flikar <- list(
  Products   = produkt_typ,
  Activities = aktivitet_typ,
  Inputs     = input_typ
)

for (f in names(typade_flikar)) {
  message("  Bearbetar: ", f, " ", format(Sys.time(), "%H:%M:%S"))
  
  resultat <- tryCatch({
    df <- jamfor_flik(f)
    df %>% mutate(typ = unname(typade_flikar[[f]][col_1]), .after = col_1)
  }, error = function(e) {
    message("  Fel i flik ", f, ": ", e$message)
    NULL
  })
  
  if (!is.null(resultat)) {
    # Varna för koder som saknar typ i mappningen
    saknas <- unique(resultat$col_1[is.na(resultat$typ)])
    if (length(saknas) > 0) {
      message("    OBS: saknar typ: ", paste(saknas, collapse = ", "))
    }
    addWorksheet(wb, f)
    writeData(wb, f, resultat)
  }
  
  rm(resultat)
  gc()
}

# --- UPR: tre separata tabeller ---
upr_tabeller <- list(
  "UPR_aktiviteter"     = "A1:J28",
  "UPR_produktkvantitet" = "A35:V43",
  "UPR_produktionsvarde" = "A50:V58"
)

for (namn in names(upr_tabeller)) {
  message("  Bearbetar: ", namn, " ", format(Sys.time(), "%H:%M:%S"))
  
  resultat <- tryCatch(
    jamfor_flik("UPR", range = upr_tabeller[[namn]]),
    error = function(e) {
      message("  Fel i ", namn, ": ", e$message)
      NULL
    }
  )
  
  if (!is.null(resultat)) {
    addWorksheet(wb, namn)
    writeData(wb, namn, resultat)
  }
  
  rm(resultat)
  gc()
}

# --- SR_inputs: markkategorier ---
message("  Bearbetar: SR_inputs_mark ", format(Sys.time(), "%H:%M:%S"))
resultat <- tryCatch(
  sr_inputs_markkategorier(),
  error = function(e) {
    message("  Fel i SR_inputs_mark: ", e$message)
    NULL
  }
)
if (!is.null(resultat)) {
  addWorksheet(wb, "SR_inputs_mark")
  writeData(wb, "SR_inputs_mark", resultat)
}
rm(resultat)
gc()

# --- SR_landArea: histosol- och mineraljord per delregion och marktyp (RTBL7C) ---
# Kolumner: delregion, marktyp, variabel (maxTot, maxHist, maxMnrl, useTot, useHist,
# useMnrl) och en kolumn per scenario. Raderna RIKET och TOTALT är summor.
message("  Bearbetar: SR_landArea ", format(Sys.time(), "%H:%M:%S"))
resultat <- tryCatch(
  jamfor_flik("SR_landArea"),
  error = function(e) {
    message("  Fel i SR_landArea: ", e$message)
    NULL
  }
)
if (!is.null(resultat)) {
  names(resultat)[1:2] <- c("SR", "I")
  addWorksheet(wb, "SR_landArea")
  writeData(wb, "SR_landArea", resultat)
}
rm(resultat)
gc()

utfil <- file.path(dir_analys, paste0("results_summary_", horisont, ".xlsx"))
saveWorkbook(wb, utfil, overwrite = TRUE)
message("Sparat: ", utfil)