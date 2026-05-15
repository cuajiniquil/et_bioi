# =======================================================================================
# 1: Set up et fonction pour histogramme/statistiques
tair10 <- read.table('etls_tair.txt', sep = '\t', header = TRUE,
                        stringsAsFactors = FALSE)

#pour regler erreur de typage:
tair10$Transposon_min_Start <- as.numeric(tair10$Transposon_min_Start)
tair10$Transposon_max_End   <- as.numeric(tair10$Transposon_max_End)

histtrnspsn <- function(famll) {
  idx <- tair10$Transposon_Family == famll
  t   <- tair10$Transposon_max_End[idx] - tair10$Transposon_min_Start[idx] + 1
  hist(t, xlab = "Taille (nt)", main = paste('Taille transposons famille', famll), nclass = 50)
  print(paste('Nombre de copies ',famll,": ",length(t)))
  print(summary(t))
}

# =======================================================================================
# 2: ADN - TAG2, ATHAT7

histtrnspsn('TAG2')
histtrnspsn('ATHAT7')

# autres familles observees: 

# BRODYAGA1A 
histtrnspsn('BRODYAGA1A')
# ATDNATA1 
histtrnspsn('ATDNATA1')


# =======================================================================================
# 3: LTR - ATLANTYS1

histtrnspsn('ATLANTYS1')

# autres familles observees: 

# ATCOPIA66 (20)
histtrnspsn('ATCOPIA66')

# =======================================================================================
# 4: LINE
# ATLINE1_1
histtrnspsn('ATLINE1_1')
