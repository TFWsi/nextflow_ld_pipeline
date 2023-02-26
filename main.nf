nextflow.enable.dsl=2

process RECODE_VCF {
    input:
    path vcf_file
    val name

    output:
    tuple path('*.recode.vcf'), val(name)

    script:
    """
    vcftools --gzvcf ${vcf_file} --recode-INFO-all --minDP 3 --thin 5 --min-meanDP 10 --minQ 20 --recode --not-chr X --not-chr Y --out ${name}
    """
}

process HAPLOTYPES {

    input:
    tuple path(vcf_file), val(name)
    path beagle

    output:
    tuple path ('*.vcf.gz'), val(name)

    script:
    """
    java -Xmx5g -jar ${beagle} gt=${vcf_file} out=${name}
    """

}

process MODIFY_GENOTYPES {

    input:
    tuple path(recoded_vcf), val(name)

    output:
    tuple path("*_modified.recode.vcf"), val(name)

    script:
    """
    perl -pe 's/\\s\\.:/\\t.\\/.:/g' ${recoded_vcf} > ${name}_modified.recode.vcf
    """
}

process CALCULATE_LD {

    publishDir "results/${name}/unfiltered", mode: "copy"

    input:
    tuple path(recoded_vcf_file), val(name)
    each chr_number

    output:
    tuple path ("*"), emit: unfiltered, val(name)

    script:
    """
    vcftools --gzvcf ${recoded_vcf_file} --chr ${chr_number} --ld-window-bp 5000 --hap-r2 --out chr${chr_number}
    """

}

process FILTER_LD {
    publishDir "results/${name}/filtered", mode: "copy"

    input:
    tuple path(file), val(name)

    output:
    path ("*"), emit: filtered

    script:
    """
    sed '/-nan/d' ${file} > filtered_${file}
    """
}

vcf_file = Channel.fromPath("data/12.vcf.gz")
beagle = Channel.fromPath("beagle.22Jul22.46e.jar")
chr_ch = Channel.of(1..18)
nam = Channel.of("SScrofa")

workflow {
    RECODE_VCF(vcf_file, nam)
    MODIFY_GENOTYPES(RECODE_VCF.out)
    HAPLOTYPES(MODIFY_GENOTYPES.out, beagle)
    CALCULATE_LD(HAPLOTYPES.out, chr_ch)
    FILTER_LD(CALCULATE_LD.out)
}
