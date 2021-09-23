## Introduction
One source of evidence for causality between two events is whether they are consistently found in the same order over time or, in short, whether they are time-concordant. We present an automatable, data-driven framework to quantify and characterize time concordance across a large set of time-series providing a novel angle to prioritize mechanistically relevant events. As a case study, we used the TG-GATEs in vivo liver data from repeat-dose studies in rats and quantified time concordance between gene expression-derived events and later adverse histopathology indicating Drug-Induced Liver Injury (DILI). This app presents the results of the paper and allows further exploration of time concordanec in the TG-GATEs data. [insert link here]
  
<img src="../figs/concept.png" width="60%", align="middle">

## App functions

#### 1) <i class="fas fa-dot-circle"></i>  Identify preceding events for defined histopathology
Here, users can explore the time concordance of different types of events (TFs, Pathways, Histopathology) preceding adverse histopathology. While in our analysis adverse histopathology was defined as a set of different histopathological findings, users can also supply their own definition, e.g. focussing only on fibrosis or biliary hyperplasia, and study events of interest based on this.

#### 2) <i class="fas fa-arrows-alt-h"></i> Look up interaction between 2 events of interest
Once 2 events of interest are identified, e.g. based on time concordance analysis from the 1st tab but also based on expert knowledge, the relation between both events can be analysed further in this 2nd tab.This will provide an overview of time series where any of the given events is observed, providing further insight into when each event was activated in each time-series.
 
## Background
#### The Opne TG-GATEs database
<img src="../figs/OpenTGGATES.png" width="60%", align="middle">
#### Defintion of adverse histopathology
<img src="../figs/histopath.png" width="60%", align="middle">

## Citation
The app was developed by Anika Liu (<a href="mailto:al862@cam.ac.uk" target="_blank"><i class="far fa-paper-plane"></i></a>) under the supervision of Dr. Andreas Bender, Dr. Namshik Han and Dr. Jordi Munoz-Muriedas. 
