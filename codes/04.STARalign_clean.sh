#!/bin/bash
# Align the reads to the genome using the QCed fq files in 2.trim_galore

# input read len = 135

index_dir="./data/00.reference/STARindex"
mkdir -p $index_dir
if [ -z "$(ls -A ${index_dir})" ]; then
	STAR \
		--runMode genomeGenerate \
		--genomeDir ${index_dir} \
		--runThreadN 20 \
		--genomeFastaFiles ./data/00.reference/genome/GRCm39.genome.fa \
		--sjdbGTFfile ./data/00.reference/genome/gencode.vM32.chr_patch_hapl_scaff.annotation.gtf \
		--sjdbOverhang 149
fi
getAlign() {
	index_dir="./data/00.reference/STARindex"
	indir="data/02.CleanData"
	outdir="./data/03.STARalign"
	line=($1)
	sampleID="${line[0]}"
	# group=${line[2]}
	# echo "Processing: "$sampleID::$group
	STAR \
		--runMode alignReads \
		--twopassMode Basic \
		--genomeDir ${index_dir} \
		--runThreadN 10 \
		--readFilesIn $indir/${sampleID}/${sampleID}_1.clean.fq.gz $indir/${sampleID}/${sampleID}_2.clean.fq.gz \
		--readFilesCommand zcat \
		--outFileNamePrefix $outdir/$sampleID/$sampleID \
		--outSAMtype BAM SortedByCoordinate \
		--outBAMsortingThreadN 5 \
		--outFilterType BySJout \
		--quantMode GeneCounts
}
export -f getAlign
# date
parallel --progress --keep-order --line-buffer getAlign :::: ./data/samples.txt
# date
/data0/apps/anaconda3/bin/multiqc -i STARalign_clean -o ./results/03.STARalign/ ./data/03.STARalign/
