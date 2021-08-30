library(shinyjs)
library(shiny)
library(shinyWidgets)
library(shinyBS)
library(ComplexHeatmap)
library(DT)
library(ggridges)
library(tidyverse)
library(viridis)


source('sub/misc_utils.R')

firstact=readRDS('files/firstact.rds')
n_ts_per_event=readRDS('files/n_ts_per_event.rds')
n_ts_per_event_freq=readRDS('files/n_ts_per_event_freq.rds')

adverse_cond=c("Biliary Hyperplasia (low)",
               "Biliary Hyperplasia (null)",
               "Biliary Hyperplasia (high)",
               "Fibrosis (low)","Fibrosis (null)",
               "Hepatocellular Necrosis (high)",
               "Hepatocellular Necrosis (low)",
               "Hepatocellular Single Cell Necrosis (high)",
               "Hepatocellular Single Cell Necrosis (low)",
               "Hepatocellular Single Cell Necrosis (null)",
               "Increased Hepatocellular Mitosis (high)",
               "Inflammation (high","Inflammation (low)")  
####Two events####
summarise_to_stats=function(source_events, target_events, select_source,select_target){
  df_new=source_events%>%
    filter(event %in% select_source)%>%
    mutate(eventtype='source')%>%
    bind_rows(target_events%>%
                filter(event %in% select_target)%>%
                mutate(eventtype='target'))%>%
#    mutate(time_index=as.numeric(SACRIFICE_PERIOD))%>%
    unique()%>%
    group_by(COMPOUND_NAME, rDOSE_LEVEL,eventtype)%>%
    filter(time_index==min(time_index))%>%
    summarise(event=paste0(event, collapse = '\ AND\ '),time_index=unique(time_index))
  
  df_new=df_new%>%
    pivot_wider(id_cols=c('COMPOUND_NAME','rDOSE_LEVEL'),names_from=eventtype,names_prefix='timeindex_',
                          values_from=time_index,values_fill=list(time_index=0))%>%
    full_join(df_new%>%
                pivot_wider(id_cols=c('COMPOUND_NAME','rDOSE_LEVEL'),names_from=eventtype,names_prefix='event_',
                            values_from=event,values_fill=list(time_index=0)))%>%
    rowwise()%>%
    mutate(description=case_when(timeindex_source==0~paste0('ONLY\ [', paste0(select_target, collapse = '\ OR \ '),']'),
                                 timeindex_target==0~paste0('ONLY\ [', paste0(select_source, collapse = '\ OR \ '),']'),
                                 timeindex_source==timeindex_target~paste0('[',paste0(select_source, collapse = '\ OR \ '), 
                                                 ']\ AND\ [',paste0(select_target, collapse = '\ OR \ '), 
                                                 ']\ AT THE SAME TIME'),
                                timeindex_source<timeindex_target~paste0('[',paste0(select_source, collapse = '\ OR \ '), ']\ BEFORE [\ ',paste0(select_target, collapse = '\ OR \ '),']'),
                           timeindex_source>timeindex_target~paste0('[',paste0(select_source, collapse = '\ OR \ '), ']\ AFTER [\ ',paste0(select_target, collapse = '\ OR \ '),']')))%>%
    mutate(class=case_when(timeindex_source==0~'only_target',
                           timeindex_target==0~'only_source',
                           timeindex_source==timeindex_target~'same_time',
                           timeindex_source<timeindex_target~'before',
                           timeindex_source>timeindex_target~'after'))%>%
    mutate(class=factor(class, levels=c('before','same_time','after','only_source','only_target')))%>%
    ungroup()%>%
    mutate(time_source=factor(timeindex_source, levels=c(1:8, 0)))%>%
    mutate(time_target=factor(timeindex_target, levels=c(1:8, 0)))
    #left_join(cond%>%select(COMPOUND_NAME, rDOSE_LEVEL,DOSE, DOSE_UNIT)%>%unique())
  levels(df_new$time_target)=c("3 hr","6 hr","9 hr","24 hr","4 day","8 day","15 day","29 day",'-')
  levels(df_new$time_source)=c("3 hr","6 hr","9 hr","24 hr","4 day","8 day","15 day","29 day",'-')
  rownames(df_new)=NULL
  return(df_new)
}
heatmap_firstact=function(df){
  library(ComplexHeatmap)
  library(RColorBrewer)
  rownames(df)=NULL
  mat=df%>%mutate(condition=paste0(COMPOUND_NAME, ' (',rDOSE_LEVEL,')'))%>%
    arrange(class,timeindex_source,timeindex_target)%>%
    mutate(source=ifelse(timeindex_source==0,NA, timeindex_source),
           target =ifelse(timeindex_target==0,NA, timeindex_target))%>%
    select(condition, source, target)%>%
    column_to_rownames('condition')%>%
    t()
  
  annot_col=df%>%mutate(condition=paste0(COMPOUND_NAME, ' (',rDOSE_LEVEL,')'))%>%
    arrange(class,time_source, time_target)%>%
    select(condition,rDOSE_LEVEL,class)%>%
    column_to_rownames('condition')%>%
    order_rdose_levels()
  
  col_dose=brewer.pal(3,'Greys')
  names(col_dose)=rev(c('rLow','rMiddle', 'rHigh'))
  col_class=c(brewer.pal(3, 'RdYlBu'),grey.colors(2,start=0, end=0.5))
  names(col_class)=c('before','same_time', 'after', 'only_source', 'only_target')
  column_ha = HeatmapAnnotation(df=annot_col,col = list(rDOSE_LEVEL=col_dose, class=col_class))
  ht=Heatmap(mat, top_annotation = column_ha, 
             cluster_columns = F, col=rev(viridis(8)), na_col = grey(0.95),
             heatmap_legend_param = list(at = seq(1:8),labels=c("3 hr","6 hr","9 hr","24 hr",
                                                                "4 day","8 day","15 day","29 day"), title = "time", legend_gp = gpar(fill = rev(viridis(8)))
             ))
  
  return(ht)
}
plot_hist=function(eventclass,select_event){
  library(ggrepel)
  df=n_ts_per_event[[eventclass]]
  
  ggplot(df, aes(n))+
    geom_histogram(binwidth = 1, fill=grey(0.6))+
    geom_text_repel(data=df%>%filter(event %in% select_event),aes(x=n, label=event), y=-0.005*n_ts_per_event_freq[[eventclass]], min.segment.length = 0.001)+
    geom_segment(data=df%>%filter(event %in% select_event),aes(x=n, xend=n,label=event), y=-0.005*n_ts_per_event_freq[[eventclass]], yend=0)+
    geom_point(data=df%>%filter(event %in% select_event),aes(x=n), y=-0.005*n_ts_per_event_freq[[eventclass]])+
    # geom_vline(xintercept = df%>%.$n, color='red')+
    xlab('Number of time-series with event')+
    ylim(-0.013*n_ts_per_event_freq[[eventclass]],NA)+
    theme_minimal()+
    ggtitle(stringr::str_wrap(paste0('Frequency of\ ', paste0(select_event, collapse=',\ '),
                                     '\ among\ ', eventclass,'\ events'),70))
  
}

####One anchoring event####

get_enrichment_directional=function(Yes, notactive_yes, No,notactive_no){
  contingency<-matrix(c(Yes, notactive_yes, No,notactive_no),
                      nrow = 2,
                      dimnames = list(Pathway = c("Present", "Not present"),
                                      Pathology = c("Present", "Not present")))
  stats=fisher.test(contingency)
  return(stats)
}

get_stats=function(source_events, target_events, select_target,bg_target, temporal_relation=c("Before", "Before or at same time")){
#Get positive cases  
  df_act_cond=target_events%>%
    filter(event %in% select_target)%>%
    mutate(eventtype='target', time_index_target=time_index, event_target=event)%>%
    select(time_index_target, COMPOUND_NAME, event_target, rDOSE_LEVEL)%>%unique()
  
  n_act_freq=nrow(df_act_cond)
  df_act=source_events%>%
    mutate(time_index_source=time_index)%>%
    select(-time_index)%>%
    inner_join(df_act_cond)
  
  if(temporal_relation=='Before'){
    df_act_freq=df_act%>%
      filter(time_index_source<time_index_target)%>%
      group_by(event)%>%
      summarise(eventfreq_active=n())
  }
  if(temporal_relation=='Before or at same time'){
    df_act_freq=df_act%>%
      filter(time_index_source<=time_index_target)%>%
      group_by(event)%>%
      summarise(eventfreq_active=n())
  }
  

  ###Background###
  df_not_in_bg_cond=target_events%>%
    filter(!event %in% bg_target)%>%
    mutate(eventtype='target', time_index_target=time_index, event_target=event)%>%
    select(time_index_target, COMPOUND_NAME, event_target, rDOSE_LEVEL)%>%unique()
  
  df_bg=source_events%>%
    mutate(time_index_source=time_index)%>%
    select(-time_index)%>%
    left_join(df_bg_cond)%>%
    filter(is.na(time_index_target))
  
  df_bg_freq=df_bg%>%
    group_by(event)%>%
    summarise(eventfreq_bg=n())
  
  n_bg_freq=df_bg%>%select(COMPOUND_NAME, rDOSE_LEVEL)%>%unique()%>%nrow()
  df_comb=left_join(df_act_freq,df_bg_freq)%>%
    ungroup()%>%
    rowwise()%>%
    mutate(n_cond_bg=n_bg_freq, n_cond_active=n_act_freq)%>%
    mutate('jaccard'=eventfreq_active/(n_cond_active+eventfreq_bg),
           'PPV'=eventfreq_active/n_cond_active,
           'TPR'=eventfreq_active/(eventfreq_active+eventfreq_bg),
           'odds_ratio'=get_enrichment_directional(Yes = eventfreq_active, 
                                                   notactive_yes = eventfreq_bg,
                                                   No = n_cond_active-eventfreq_active,
                                                   notactive_no = n_cond_bg-eventfreq_bg
                                                    )$estimate,
           'pval'=get_enrichment_directional(Yes = eventfreq_active, 
                                                   notactive_yes = eventfreq_bg,
                                                   No = n_cond_active-eventfreq_active,
                                                   notactive_no = n_cond_bg-eventfreq_bg
           )$p.value)

                     
return(df_comb)
}
