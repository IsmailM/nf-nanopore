
include { SINGLE_TO_MULTI_FAST5 } from './modules/utils/ont-fast5-api/main.nf'
include { DORADO_BASECALLER } from './modules/basecalling/dorado.nf'
include {INDEX_REFERENCE} from './modules/utils/index_reference.nf'
include { DORADO_ALIGNER } from './modules/alignment/dorado.nf'
include { CLAIR_CALLER } from './modules/variants/clair.nf'
include { SNIFFLES_CALLER } from './modules/variants/sniffles.nf'
include { ANNOTATION_SNPEFF } from './modules/annotation/snpeff.nf'
include { ANNOTATION_VEP } from './modules/annotation/vep.nf'
include { PHASING } from './modules/variants/whatshap.nf'
include { MODKIT } from './modules/methylation/modkit.nf'
include { BASECALLED_FASTQ } from './modules/utils/bam2fastq.nf'
include { QC_FASTP_LONG } from './modules/qc/fastp_long.nf'
include { QC_MOSDEPTH } from './modules/qc/mosdepth.nf'
include { QC_FASTCAT_BAMSTATS } from './modules/qc/fastcat_bamstats.nf'
include { QC_TOUILLIGQC } from './modules/qc/toulligqc.nf'
include { QC_NANOPLOT } from './modules/qc/nanoplot.nf'
include { QC_CRAMINO } from './modules/qc/cramino.nf'
include { QC_CHOPPER } from './modules/qc/chopper.nf'

fast5_ch = channel.fromPath(params.fast5_dir, type: 'dir', checkIfExists: true)
ref_ch = channel.fromPath(params.ref, type: 'file', checkIfExists: true)
workflow {
    SINGLE_TO_MULTI_FAST5(fast5_ch)
    DORADO_BASECALLER(SINGLE_TO_MULTI_FAST5.out.processed_fast5)
    BASECALLED_FASTQ(DORADO_BASECALLER.out.basecalled_bam)
    INDEX_REFERENCE(ref_ch)
    DORADO_ALIGNER(DORADO_BASECALLER.out.basecalled_bam, INDEX_REFERENCE.out.ref)
    CLAIR_CALLER(DORADO_ALIGNER.out.aligned_bam, INDEX_REFERENCE.out.ref)
    SNIFFLES_CALLER(DORADO_ALIGNER.out.aligned_bam, INDEX_REFERENCE.out.ref)
    // ANNOTATION_SNPEFF(CLAIR_CALLER.out.variants_vcf)
    ANNOTATION_VEP(CLAIR_CALLER.out.variants_vcf)
    PHASING(DORADO_ALIGNER.out.aligned_bam, CLAIR_CALLER.out.variants_vcf, INDEX_REFERENCE.out.ref)
    MODKIT(DORADO_ALIGNER.out.aligned_bam, INDEX_REFERENCE.out.ref)
    QC_FASTP_LONG(BASECALLED_FASTQ.out.basecalled_fastq)
    QC_MOSDEPTH(DORADO_ALIGNER.out.aligned_bam)
    QC_FASTCAT_BAMSTATS(BASECALLED_FASTQ.out.basecalled_fastq, DORADO_ALIGNER.out.aligned_bam)
    QC_TOUILLIGQC(BASECALLED_FASTQ.out.basecalled_fastq, DORADO_ALIGNER.out.aligned_bam)
    QC_NANOPLOT(BASECALLED_FASTQ.out.basecalled_fastq)
    QC_CRAMINO(DORADO_ALIGNER.out.aligned_bam)
    // QC_CHOPPER(BASECALLED_FASTQ.out.basecalled_fastq)
}

