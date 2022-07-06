order_timepoints<-function(df){
  df_new<-df%>%separate(SACRIFICE_PERIOD, into = c("time", "timeunit"), sep=" ", remove = F)%>%
    arrange(desc(timeunit), as.numeric(time))%>%
    mutate(SACRIFICE_PERIOD=factor(SACRIFICE_PERIOD, levels = c("3 hr","6 hr","9 hr","24 hr",
                                                                "4 day","8 day","15 day","29 day")))%>%
    dplyr::select(-timeunit, -time)
  return(df_new)
}

order_rdose_levels<-function(df){
  df_new<-df%>%
    mutate(rDOSE_LEVEL=factor(rDOSE_LEVEL, levels = c("rLow","rMiddle", "rHigh")))
  return(df_new)
}

format_direction=function(df){
  df_new=df%>%mutate(direction=case_when(direction==-1~ 'Down',
                                         direction==1 ~'Up'))
  return(df_new)
}
