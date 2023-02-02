nextflow.enable.dsl=2

process kraken2 {

    cpus 8

    publishDir "${params.outdir}", pattern: "${row.cid}.k2*", mode: 'copy'

    input:
        tuple val(row), path(fastq_gz)
    
    output:
        tuple val(row), path("${row.cid}.k2_report"), path("${row.cid}.k2_out")


    """
    kraken2 --db ${params.k2_db} --threads ${task.cpus} --gzip-compressed --report ${row.cid}.k2_report ${fastq_gz} > ${row.cid}.k2_out
    """
    

}

workflow {

    Channel
        .fromPath(params.metadata)
        .splitCsv(header: true)
        .map {
            it ->
            [it, file(it.file_url)]
        }
        .set { metadata_ch }

    kraken2(metadata_ch)
    
}