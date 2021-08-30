cond=read.csv('files/conditions_min4_not0.csv')
pw_annot=read.csv('files/pathway_msigdbr.csv')%>%select(gs_description,gs_name)%>%unique()
first_tf=read.csv('files/first_activation/dorothea/ABC_firstactive_logFC_0.csv', row.names = 1)%>%
  mutate(event=gene)%>%arrange(event)%>%
  select(event, rDOSE_LEVEL, COMPOUND_NAME, SACRIFICE_PERIOD)%>%order_timepoints()%>%
  unique()
first_histo=read.csv('files/first_activation/histopath/firstact_toxscore_sutherland.csv', row.names = 1)%>%
  mutate(event=paste0(toxlabel, gsub(toxact, pattern = 'toxact_', replacement = '\ ('),')'))%>%arrange(event)%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern = '_', replacement = '\ '))%>%
  select(event, rDOSE_LEVEL, COMPOUND_NAME, SACRIFICE_PERIOD)%>%order_timepoints()%>%
  unique()
first_pathway=read.csv('files/first_activation/msigdb/reactome_firstactive_logFC_0.csv', row.names = 1)%>%
  mutate(gs_name=gene)%>%
  left_join(pw_annot)%>%
  mutate(event=gs_description)%>%
  arrange(event)%>%
  select(event, rDOSE_LEVEL, COMPOUND_NAME, SACRIFICE_PERIOD)%>%order_timepoints()%>%
  unique()
firstact=list(TF=first_tf, Histopathology=first_histo, Pathway=first_pathway)
n_ts_per_event=lapply(firstact, FUN = function(df){df%>%select(event, rDOSE_LEVEL, COMPOUND_NAME)%>%unique()%>%group_by(event)%>%summarise(n=n())})
n_ts_per_event_freq=lapply(n_ts_per_event, FUN=function(df){df%>%group_by(n)%>%summarise(freq=n)%>%.$freq%>%max()})


cel_tp_wlevel<-read.csv('../../processed_data/TGGate/conditions_min4_not0.csv')%>%
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern='\ ',replacement='_'))%>%
  select(-SINGLE_REPEAT_TYPE)%>%
  unique()

df_histo_mintime=first_histo%>%
  order_timepoints()%>%
  mutate(time_index=as.numeric(SACRIFICE_PERIOD))%>% 
  mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern='\ ',replacement='_'))%>%
  group_by(COMPOUND_NAME,rDOSE_LEVEL,event)%>%
  filter(time_index==min(time_index))%>%
  ungroup()

df_histo_present=df_histo_mintime%>%
  select(COMPOUND_NAME, rDOSE_LEVEL)%>%
  unique()

df_no_histo_control=cel_tp_wlevel%>%
  select(COMPOUND_NAME, rDOSE_LEVEL)%>%
  unique()%>%
  left_join(df_histo_present%>%
              mutate(histo_present=T))%>%
  filter(is.na(histo_present))%>%
  select(COMPOUND_NAME, rDOSE_LEVEL)