# EEG-Fringe-P3-analysis
This repository contains code for my MSc dissertation and an ongoing research project that I am working on as lead author, alongside Professor Howard Bowman and Dr Alberto Aviles at the University of Birmingham, with the intention to seek its publication upon completion.

## Background
This project constitutes an analysis of electroencephalography (EEG) data collected from an experiment conducted by Dr Aviles, in which subjects viewed streams of faces presented via Rapid Serial Visual Presentation (RSVP), within a paradigm known as the Fringe-P3 technique. In analysing the electrophysiological responses to faces of different forms and strengths of personal significance to the subjects (referred to as 'salience'), we aim to detect a neural signal known as the P300 (P3) - an electrophysiological response recognised as a reliable neural signature of perceived salience - and examine how differences in the form or strength of perceived salience can affect this pattern of neural responding. In doing so, this research aims to add to our current scientific understanding of the P3 component and determine the utility of the Fringe-P3 technique in discerning what individuals perceive as salient, without them ever explicitly communicating this information.

Please see my research proposal (located in the Proposal/ folder of this repository) for a full description of the research aims and methods.

## Disclaimer
This project is an ongoing work-in-progress. The files and folders in this repository may be incomplete, contain errors and/or not up to date.

## Contents
- README.md: (this file)
- Proposal/: a folder containing the research proposal report for the project (in .docx and .md format). This report outlines the background, aims, methodology and planned analysis of the study.
- Code/: a folder containing the required code for this project.
- Poster/: a folder containing a PDF poster that summarises the research project, used for my MSc dissertation project presentation.

## Code/
The code/ folder contains the following:
- Preprocessing/: a folder containing all scripts and functions used in the data preproccessing of this project.
- ERP/: a folder containing all scripts and functions used to generate the Event-Related Potentials of this project.
- Analysis/: a folder containing all scripts and functions used in the data analysis of this project.

In the Preprocessing/ folder, the following code is available:

- preprocess.m: a function that applies all of our initial preprocessing steps to input raw data - including segmentation, baseline-correction, band-pass filtering, band-stop filtering, re-referencing and artifact exclusion thresholding.
- preprocessing.m: a script that loads the raw data, calls the custom preprocess() function to apply the pipeline, then facilitates Independent Component Analysis and channel/trial rejection for further data cleaning.

In the ERP/ folder, the following code is available:

- generateSubjectERPs.m: a function that generates the subject-level ERPs by averaging across pairs of trials that involve adjacent probe/irrelevant morph presentations.
- erpGeneration.m: a script that calls the generateSubjectERPs() function to generate the subject-level ERPs, then tidies/prepares the array containing these averaged signals for the subsequent statistical analysis by removing empty cells and any ERPs that do not have a probe/irrelevant equivalent. The script then includes code to optionally adjust the latency of the subject-level ERPs, code to average across the subject-level ERPs to generate the group-level ERPs, as well as code to visualise the resulting group-level signals.

In the Analysis/ folder, the following code is available:

- groupLevelAnalysis.m: a script that runs the cluster-based paired-samples permutation test to compare the subject-level ERPs of the probe and irrelevant conditions of each pair level, in each block. The script first defines the neighbours for each channel in the data (to be later used in clusters), then runs the permutation test and plots the significant clusters on topographic maps over time.

## Acknowledgements
This project is being conducted in collaboration with Professor Howard Bowman at the University of Birmingham.

This project uses data collected by Dr Alberto Aviles, as a part of his PhD under the supervision of Professor Howard Bowman.

Invaluable guidance on this project has been provided by PhD student Cihan Dogan, from the University of Kent.

This project utilises the FieldTrip toolbox for data preprocessing and analysis, developed by Oostenveld, R., Fries, P., Maris, E. & Schoffelen, J. M. (2011), at the Donders Institute for Brain, Cognition and Behaviour.
