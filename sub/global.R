library(shinyjs)
library(shiny)
library(shinyWidgets)
library(shinyBS)
library(ComplexHeatmap)
library(cowplot)
library(plotly)
library(DT)
library(ggridges)
library(tidyverse)
library(scales)
library(viridis)
library(GGally)
library(shinyHeatmaply)
library(shinycssloaders)
library(ggiraph)

source('sub/misc_utils.R')

firstact=readRDS('files/firstact.rds')
topact=readRDS('files/topact.rds')

get_topstats=function(topact, conds){
  
}

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
    mutate(description=case_when(timeindex_source==0~'Only later event activated in time-series',
                                 timeindex_target==0~'Only preceding event activated in time-series',
                                 timeindex_source==timeindex_target~'First activation of preceding and later event at the same time',
                                timeindex_source<timeindex_target~'First activation of preceding event before later event',
                           timeindex_source>timeindex_target~'First activation of preceding event after later event'))%>%
    mutate(class=case_when(timeindex_source==0~'only_later',
                           timeindex_target==0~'only_preceding',
                           timeindex_source==timeindex_target~'same_time',
                           timeindex_source<timeindex_target~'before',
                           timeindex_source>timeindex_target~'after'))%>%
    mutate(class=factor(class, levels=c('before','same_time','after','only_preceding','only_later')))%>%
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
  m_source=df%>%mutate(condition=paste0(COMPOUND_NAME, ' (',rDOSE_LEVEL,')'))%>%
    mutate(event=event_source, timeindex=timeindex_source)%>%
    select(COMPOUND_NAME, rDOSE_LEVEL,condition, event, timeindex)%>%unique()%>%
    filter(!is.na(event))%>%
    separate_rows(event, sep='\ AND\ ')
  
  m_target=df%>%mutate(condition=paste0(COMPOUND_NAME, ' (',rDOSE_LEVEL,')'))%>%
    mutate(event=event_target, timeindex=timeindex_target)%>%
    select(COMPOUND_NAME, rDOSE_LEVEL,condition, event, timeindex)%>%unique()%>%
    filter(!is.na(event))%>%
    group_by(COMPOUND_NAME, rDOSE_LEVEL,condition)%>%
    filter(timeindex==min(timeindex))%>%
    mutate(event='target')
  
  annot_col=df%>%mutate(condition=paste0(COMPOUND_NAME, ' (',rDOSE_LEVEL,')'))%>%
    arrange(class,time_source, time_target)%>%
    select(condition,rDOSE_LEVEL,class)
  
  mat=bind_rows(m_target,m_source)%>%left_join(annot_col)%>%
    pivot_wider(id_cols = c('condition','class','rDOSE_LEVEL'),
                names_from=event, values_from=timeindex)%>%
    arrange_at(c('class','target',unique(m_source$event)))%>%
    ungroup()
  # mat[is.na(mat)]=0
  
  
  ht=heatmaply(mat%>%select(-class, -rDOSE_LEVEL)%>%column_to_rownames('condition')%>%t(),
               Rowv = FALSE,Colv = FALSE,
               col_side_colors=mat%>%select(class, condition)%>%column_to_rownames('condition'), 
               showticklabels = T, margins = c(10,200))
  return(ht)
}
plot_hist=function(eventclass,select_event,type){
  library(ggrepel)
  df=n_ts_per_event[[eventclass]]
  
  g=ggplot(df, aes(n))+
    geom_histogram(binwidth = 1, fill=grey(0.6))+
    # geom_text_repel(data=df%>%filter(event %in% select_event),aes(x=n, label=event), y=-0.005*n_ts_per_event_freq[[eventclass]], min.segment.length = 0.001)+
    # geom_segment(data=df%>%filter(event %in% select_event),aes(x=n, xend=n,label=event), y=-0.005*n_ts_per_event_freq[[eventclass]], yend=0)+
    geom_point_interactive(data=df%>%filter(event %in% select_event),aes(x=n,tooltip = event, data_id = event ), y=0)+
    # geom_vline(xintercept = df%>%.$n, color='red')+
    xlab(paste0('Number of time-series with \n ',eventclass,' event'))+
    # ylim(-0.013*n_ts_per_event_freq[[eventclass]],NA)+
    theme_minimal()+
    ggtitle(paste0('Frequency of\ ',type,'\ events'))
  girafe(ggobj = g,width_svg = 3,height_svg = 3,
          options = list(opts_hover_inv(css = "opacity:0.5"),
                         opts_hover(css = "fill:wheat;stroke:orange;r:6pt;"),
                         opts_selection(type = "single")
          )
  )

  }


####One anchoring event####

get_enrichment_directional=function(Yes, notactive_yes, No,notactive_no){
  contingency<-matrix(c(Yes, notactive_yes, No,notactive_no),
                      nrow = 2,
                      dimnames = list(Pathway = c("Present", "Not present"),
                                      Pathology = c("Present", "Not present")))
  stats=fisher.test(contingency, alternative = "greater")
  return(stats)
}

filter_by_temporal_relation=function(df,include_same_time){
  if(include_same_time){
    df_new=df%>%filter(as.numeric(time_index_source)<=as.numeric(time_index_target))
  }else{
    df_new=df%>%filter(as.numeric(time_index_source)<as.numeric(time_index_target))
  }
  return(df_new)
}
get_stats=function(source,top_events, select_target,bg_target, include_same_time){
#Get positive cases  
  df_act_cond=firstact$Histopathology%>%
    filter(event %in% select_target)%>%
    mutate(eventtype='target', time_index_target=time_index, event_target=event)%>%
    group_by(COMPOUND_NAME,rDOSE_LEVEL)%>%summarise(time_index_target=min(time_index_target))
  
  df_act=firstact[[source]]%>%
    mutate(time_index_source=time_index)%>%
    select(-time_index)%>%
    inner_join(df_act_cond)

  if(source!='Histopathology'){
  df_acttop=top_events%>%
    mutate(time_index_source=time_index)%>%
    select(-time_index)%>%
    inner_join(df_act_cond)%>%
    filter_by_temporal_relation(df = ., include_same_time)%>%
    group_by(COMPOUND_NAME, rDOSE_LEVEL, event, direction)%>%
    filter(abs(logFC)==max(abs(logFC)))%>%
    group_by(event, direction)%>%
    summarise(logFC=abs(median(logFC)))
  }
  
  
    df_act_freq=df_act%>%
      filter_by_temporal_relation(df = ., include_same_time)%>%
      group_by(event,direction)%>%
      summarise(active=n())
    n_act_freq=df_act%>%select(COMPOUND_NAME, rDOSE_LEVEL)%>%unique()%>%nrow()
  ###Background###
  df_not_in_bg_cond=firstact$Histopathology%>%
    filter(!event %in% bg_target)%>%
    mutate(eventtype='target', time_index_target=time_index, event_target=event)%>%
    select(time_index_target, COMPOUND_NAME, event_target, rDOSE_LEVEL)%>%unique()
  
  df_bg=firstact[[source]]%>%
    mutate(time_index_source=time_index)%>%
    select(-time_index)%>%
    left_join(df_not_in_bg_cond)%>%
    filter(is.na(time_index_target))
  
  df_bg_freq=df_bg%>%
    select(COMPOUND_NAME, rDOSE_LEVEL, event, direction)%>%
    unique()%>%
    group_by(event,direction)%>%
    summarise(bg=n())

  n_bg_freq=df_bg%>%select(COMPOUND_NAME, rDOSE_LEVEL)%>%unique()%>%nrow()
  df_result=left_join(df_act_freq,df_bg_freq)%>%
    ungroup()%>%
    rowwise()%>%
    mutate(n_cond_bg=n_bg_freq, n_cond_active=n_act_freq, bg=ifelse(is.na(bg),0,bg))%>%
    mutate('ratio_active'=active/n_cond_active,
           'ratio_bg'=bg/n_cond_bg,
           'jaccard'=active/(n_cond_active+bg),
           'TPR'=active/n_cond_active,
           'PPV'=active/(active+bg),
           'n_active_total'=n_act_freq,
           'n_bg_total'=n_bg_freq)%>%
    mutate('lift'=(active/(n_cond_active+n_cond_bg))/(n_cond_active/(n_cond_bg+n_cond_active)*((active+bg)/(n_cond_bg+n_cond_active))))%>%
    mutate('odds_ratio'=get_enrichment_directional(Yes = active,
                                                   notactive_yes = bg,
                                                   No = n_cond_active-active,
                                                   notactive_no = n_cond_bg-bg
                                                    )$estimate,
           'pval'=get_enrichment_directional(Yes = active,
                                                   notactive_yes = bg,
                                                   No = n_cond_active-active,
                                                   notactive_no = n_cond_bg-bg
           )$p.value)%>%select(-n_cond_bg, -n_cond_active)%>%
    arrange(pval)
  if(source!='Histopathology'){
    df_result=df_result%>%
      left_join(df_acttop)%>%
      mutate(logFC=signif(logFC,3))
  }
return(df_result)
}
cols <- c('Down'="#00468BFF", 'Up'="#ED0000FF")

