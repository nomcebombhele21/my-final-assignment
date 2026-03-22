#!/usr/bin/env nextflow
//Check raw read quality:
process FASTQC {
 input:
  tuple val(id), path(reads)

  output:
   path "*_fastqc.*"

  script:
   """
fastqc ${reads[0]} ${reads[1]}
   """
}
// Cleans the reads by removing the low quality reads using the singularity container.
process TRIMMOMATIC {
  container "/users/user02/sif/trimmomatic.sif" 
  
  input: 
  tuple val(id), path(reads)
  
  output:
   tuple val(id), path("${id}_R*_paired.fastq"), emit: trim_fq
  
  script: 
   """
   java -jar /opt/Trimmomatic-0.39/trimmomatic-0.39.jar PE \
      ${reads[0]} ${reads[1]} \
      ${id}_R1_paired.fastq ${id}_R1_unpaired.fastq \
      ${id}_R2_paired.fastq ${id}_R2_unpaired.fastq \
      SLIDINGWINDOW:4:20
   """
}
//Map clean reads to the reference genome(chromosome 19)
process BWA {
  publishDir "${params.outdir}", mode: 'copy', overwrite: true
 
  input:
   path chr19
   tuple val(id), path(reads)
  
  output: 
   tuple val(id), path("*.sam"), emit: bwa_sam
  
  script:
  """
   bwa mem -t 2 ${chr19}/chr19.fa $reads > ${id}.sam
  """
}
//Converts SAM output to compressed BAM and sort.
process SAM2BAM {
  input: 
   tuple val(id), path(sam)
  
  output:
   tuple val(id), path("${id}.bam"), emit: bam
  
  script:
   """
   samtools view -Sb $sam > ${id}.bam
   """

}
//Identification of genetic variants.
process VARCALL {
  publishDir "${params.outdir}/vcf", mode: 'copy'
  
  input: 
   tuple val(id), path(bam)
   path chr19Folder
  
  output: 
   path "${id}.vcf", emit: vcf

  script: 
   """
   samtools sort ${bam} -o ${id}_sorted.bam
    samtools index ${id}_sorted.bam
   bcftools mpileup -Ou -f ${chr19Folder}/chr19.fa ${id}_sorted.bam | bcftools call -mv -Ov > ${id}.vcf
   """
}

workflow {
  def fastq = Channel.fromFilePairs(params.fastq)
  def output = Channel.fromPath(params.outdir)
  def chr19 = Channel.fromPath(params.chr19Folder)
  FASTQC(fastq)
  def trimmed = TRIMMOMATIC(fastq)
  def aligned = BWA(chr19, trimmed)
  def bam = SAM2BAM(aligned)
  VARCALL(bam, chr19)

}
