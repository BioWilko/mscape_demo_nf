nextflow.enable.dsl=2

process kraken2 {

    conda '$baseDir/environments/kraken2.yaml'

    cpus 8

    publishDir "${params.outdir}", pattern: "${row.cid}.k2*", mode: 'copy'

    input:
        val(row)
    
    output:
        tuple val(row), path("${row.cid}.k2_report"), path("${row.cid}.k2_out")


    """
    kraken2 --db ${params.k2_db} --threads ${task.cpus} --gzip-compressed --report ${row.cid}.k2_report ${row.file_url} > ${row.cid}.k2_out
    """
    

}

workflow {

    Channel
        .fromPath(params.metadata)
        .splitCsv(header: true)
        .set { metadata_ch }

    kraken2(metadata_ch)
    
}