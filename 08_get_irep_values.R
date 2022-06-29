library(dplyr)

samples = c('SampleNameReplace')

df1 = read.csv(file = 'binning_das_tool/binning_table_all_simple.tsv', sep = '\t', header = TRUE)

col1 = c( 'bin',
          'un-filtered index of replication (iRep)',
          'raw index of replication (no GC bias correction)',
          'r^2',
          'coverage',
          'windows passing filter',
          'fragments/Mbp',
          'GC bias',
          'GC r^2')

irep_values = c()

for (sample in samples){
  df1.tmp <-df1[df1$Sample==sample,]
for (x in df1.tmp$Bin){
  print(x)
  filepath = paste("irep/", sample,"__", x, "_irep_dastool.tsv", sep= "")
  print(filepath)
  df2=read.table(file = filepath, sep = '\t', header = FALSE)
  df2 = as.data.frame((df2))
  df2[1,2] = x
  df2$V1 = col1
  irep_values = c(df2[2,2],irep_values)
}}

df1$irep_values = irep_values
new_df <- df1 %>% select(irep_values, everything())
new_df <- new_df %>% select(best_species, everything())


write.csv(new_df,"irep/irep_summary.csv", row.names = FALSE)


