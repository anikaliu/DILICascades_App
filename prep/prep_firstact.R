library(tidyverse)
format_direction=function(df){
  df_new=df%>%mutate(direction=case_when(direction==-1~ 'Down',
                                         direction==1 ~'Up'))
  return(df_new)
}

pw_annot=read.csv('files/pathway_msigdbr.csv')
first_tf=read.csv('prep/first_activation/dorothea/ABC_firstactive_logFC_0.csv', row.names = 1)%>%
  mutate(event=gene)%>%arrange(event)%>%
  select(-gene)%>%rowwise()%>%
  format_direction()%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern = '\\ ',replacement = '_'))%>%
  mutate(event=paste0(event, ' (', direction, ')'))

first_histo=read.csv('prep/first_activation/histopath/firstact_toxscore_sutherland.csv', row.names = 1)%>%
  mutate(toxact=gsub(toxact, pattern = 'toxact_', replacement = ''))%>%
  mutate(event=paste0(toxlabel,' (', toxact,')'))%>%arrange(event)%>%
  rowwise()%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern = '\\ ',replacement = '_'),
         direction=1)%>%
  format_direction()

first_pathway=read.csv('prep/first_activation/msigdb/reactome_firstactive_logFC_0.csv', row.names = 1)%>%
  mutate(gs_name=gene)%>%left_join(pw_annot%>%select(gs_name, gs_description)%>%unique())%>%
  mutate(event=gs_description)%>%
  select(-gs_name, -gs_description, -gene)%>%
  arrange(event)%>%
  rowwise()%>%
  format_direction()%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern = '\\ ',replacement = '_'))%>%
  mutate(event=paste0(event, ' (', direction, ')'))

firstact=list(TF=first_tf, Histopathology=first_histo, Pathway=first_pathway)
saveRDS(firstact, 'files/firstact.rds')

n_ts_per_event=lapply(firstact, function(df){
  event_freq=df%>%select(event, COMPOUND_NAME, rDOSE_LEVEL)%>%unique()%>%group_by(event)%>%summarise(n=n())
  return(event_freq)
})
saveRDS(n_ts_per_event, 'files/n_ts_per_event.rds')

n_ts_per_event_freq=lapply(n_ts_per_event, function(x){x%>%group_by(n)%>%summarise(freq=n())%>%max(.$freq)})
saveRDS(n_ts_per_event_freq, 'files/n_ts_per_event_freq.rds')

top_tf=read.csv('prep/sigstats/dorothea_ABC/sig_logFC_adverse.csv', row.names = 1)%>%
  mutate(event=gene)%>%arrange(event)%>%
  select(-gene)%>%rowwise()%>%
  
  format_direction()%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern = '\\ ',replacement = '_'))%>%
  mutate(event=paste0(event, ' (', direction, ')'))

top_pathway=read.csv('prep/sigstats/reactome/sig_logFC_adverse.csv', row.names = 1)%>%
  mutate(gs_name=gene)%>%left_join(pw_annot%>%select(gs_name, gs_description)%>%unique())%>%
  mutate(event=gs_description)%>%
  select(-gs_name, -gs_description, -gene)%>%
  arrange(event)%>%rowwise()%>%
  format_direction()%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern = '\\ ',replacement = '_'))%>%
  mutate(event=paste0(event, ' (', direction, ')'))

top=list(TF=top_tf, Pathway=top_pathway, Histopathology=first_histo%>%mutate(direction=1))
saveRDS(top, 'files/topact.rds')
