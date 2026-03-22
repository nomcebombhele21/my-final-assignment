#Biocomputing Assignment

#1. #Creating the singularity Trimmomatic definition file.:
#A singularity container was created to run Trimmomatic using Ubuntu 22.04 as the base image.
    #The steps were as follows: #Created a trimmomatic definition file called trimmomatic.def. 
                                #Used Docker bootstrap with ubuntu:22.04
                                #Installed the following dependenices: # -default-jre
                                                                        #- wget
                                                                        # - unzip
                                #Downloaded Trimmomatic v0.39
                                #Set environment variable and runscript
    #Build command: #singularity build trimmomatic.sif trimmomatic.def

#2. Nextflow Pipeline
    #This pipeline processes pair-end WGS data through the following steps:
        #FastQC: Quality check of raw reads.
        #Trimmomatic: Low quality reads and adapters were removing using the singularity container.
        #BWA: Alignment of clean reads to reference genome (chromosome 19)
        #SAMtoBAM: Comversion of SAM files to sorted BAM files using samtools.
        #VARCALL: Variant calling to produce a vcf file using bcftools.
    #Input: Paired-end FASTQ files
    #Output: Trimmed FASTQ files
             #SAM/BAM alignment files
             #VCF file containing variants
    #The following tools were loaded to run the pipeline: fastqc, bwa, samtools and bcftools.
    #To tun the pipeline: ./run-pipe OR nextflow run main.nf -config nextflow.config
    #After running the pipeline the vcf file was saved in vcf directory which is the output directory which was in the wgs/pipeline directory.

#3. Storing VCF file into the SQLite3 Database
    #The final variants of the vcf file were extracted and stored in the SQLite3 database table called "variants.db".
    #The vcf file was converted into a csv file first to remove the extra notes and columns and have only clean spreadsheet with the needed columns.
    #The following steps in SQLite3 Databse: 
        #Create table called variants which has the following columns:
            #Chromosome TEXT: -The chromosome identifier
            #Position INTEGER: -The loaction of a variant in a chromosome.
            #Reference_allele TEXT: -The nucleotide base in the reference genome
            #Alternative_allele TEXT: -The observed mutation in the genome.
            #Quality REAL: The Phred quality score.
        #After creating table, the variants.csv file was imported in the table.
#4. The repository contains:
    #Trimmomatic.def file
    #Nextflow pipeline: main.nf
    #nextflow.config
    #variants.db (SQLite3 Databse)
    #README.md
        
