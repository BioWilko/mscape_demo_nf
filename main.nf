nextflow.enable.dsl=2

process kraken2 {

    cpus 20

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "${row.cid}.k2*", mode: "copy"

    input:
        tuple val(row), path(fastq_gz)
    
    output:
        tuple val(row), path("${row.cid}.k2_report"), path("${row.cid}.k2_out")


    """
    kraken2 --db ${params.k2_db} --threads ${task.cpus} --gzip-compressed --report ${row.cid}.k2_report ${fastq_gz} > ${row.cid}.k2_out
    """
    

}

process krona {

    publishDir "${params.outdir}/${task.process.replaceAll(":","_")}", pattern: "${row.cid}_kronaplot.html", mode: "copy"

    maxForks 1

    input:
        tuple val(row),  path(k2_report), path(k2_out)
    
    output:
        path("${row.cid}_kronaplot.html")

    """
    ktUpdateTaxonomy.sh
    ktImportTaxonomy -m 3 -t 5 -o ${row.cid}_kronaplot.html ${k2_report}
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

    krona(kraken2.out)
    
}