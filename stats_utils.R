get_ks=function(conditions){
  n_DEG_gex_pergene<-rbindlist(
    future_map(conditions$filename, 
               function(x){
                 df=read.csv(x, row.names = 1)%>%
                   rownames_to_column('gene')%>%
                   mutate('filename'=x)
                 return(df)
               }
    )
  )%>%left_join(conditions)
  
  DE_by_gene_list=n_DEG_gex_pergene%>%split(f=.$gene, lex.order = T)
  
  ks_pval_list=future_map(DE_by_gene_list,
                          function(x){
                            ks.test(x$logFC[which(x$`adverse?`=='Yes')],
                                    x$logFC[which(x$`adverse?`=='No')], 
                                    exact=TRUE)$p.value})
  
  output=data.frame('ks_pval'=unlist(ks_pval_list))
  return(output)
}

#####Functions#####
get_enrichment_directional_pval<-function(Yes, notactive_yes, No,notactive_no, alternative='greater'){
  contingency<-matrix(c(Yes, notactive_yes, No,notactive_no),
                      nrow = 2,
                      dimnames = list(Pathway = c("Present", "Not present"),
                                      Pathology = c("Present", "Not present")))
  stats=fisher.test(contingency, alternative = alternative)
  return(stats$p.value)
}
get_enrichment_directional_odds<-function(Yes, notactive_yes, No,notactive_no){
  contingency<-matrix(c(Yes, notactive_yes, No,notactive_no),
                      nrow = 2,
                      dimnames = list(Pathway = c("Present", "Not present"),
                                      Pathology = c("Present", "Not present")))
  stats=fisher.test(contingency)
  return(stats$estimate)
}

get_path_ORA=function(filename,cel_tp_wlevel,pathreview,n_background){
  if(is.character(filename)){
    df=read.csv(filename, row.names = 1)%>%
      mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern='\ ',replacement='_'))%>%
      left_join(pathreview)%>%
      unique()%>%
      group_by(gene,direction,`adverse?`)%>%
      summarise(n=n())%>%
      pivot_wider(names_from=`adverse?`, values_from=n, values_fill=list(n=0))%>%
      ungroup()%>%
      rowwise()%>%
      mutate(notactive_no=n_background$No-No,notactive_yes=n_background$Yes-Yes)%>%
      mutate(pval_hypergeometric=get_enrichment_directional_pval(Yes, notactive_yes, No,notactive_no))%>%
      mutate(odds_hypergeometric=get_enrichment_directional_odds(Yes, notactive_yes, No,notactive_no))%>%
      ungroup()%>%
      mutate(FDR_hypergeometric=p.adjust(pval_hypergeometric))
  }
  if(is.data.frame(filename)){
    df=filename%>%
      mutate(COMPOUND_NAME=gsub(COMPOUND_NAME, pattern='\ ',replacement='_'))%>%
      left_join(pathreview)%>%
      unique()%>%
      group_by(gene,direction,`adverse?`)%>%
      summarise(n=n())%>%
      pivot_wider(names_from=`adverse?`, values_from=n, values_fill=list(n=0))%>%
      ungroup()%>%
      rowwise()%>%
      mutate(notactive_no=n_background$No-No,notactive_yes=n_background$Yes-Yes)%>%
      mutate(pval_hypergeometric=get_enrichment_directional_pval(Yes, notactive_yes, No,notactive_no))%>%
      mutate(odds_hypergeometric=get_enrichment_directional_odds(Yes, notactive_yes, No,notactive_no))%>%
      ungroup()%>%
      mutate(FDR_hypergeometric=p.adjust(pval_hypergeometric))
  }

  return(df)
}
