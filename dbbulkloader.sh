#!/bin/bash
echo "Gbrowser2 MySQL Bulk data loading"
echo "V0.1.0-Beta Testing"
echo "header file : chr?.gff / fasta hg19 file : chr?.fasta"
echo "Usage vcf2gbrowsebulkloader.sh [Target VCF] [Target ANNOVAR TXT File] [MySQL DB name] [NCBI/Ensemble]"
echo "Autosome + Sex chromosome site will be extracted and applied"



kill () {
echo >&2 "$@"
exit 1
}

[ -n "$4" ] || kill "DB feature is not provided"
[ -n "$3" ] || kill "MySQL DB name is not provided"
[ -f "$2" ] || kill "ANNOVAR file is not provided"
[ -f ./chr1.header ] || kill "GFF3 header file is not exist."
[ -f "$1" ] || Kill "Required file is not available."
echo MYSQLDB:"$3"
echo "$4"

var1="$3"
var2="$4"
var3="$2"
mysql -e "desc ${var1}.feature" > /dev/null 2>&1 || bp_seqfeature_load.pl -c -f -d "$3" chr0.gff chr0.fa



NCBI () {
cat chr${i}.gff.bed.tmp | sed '{s/,/|/g}' | sed '{s/SNP/NCBI/g}' | awk '{OFS="\t";FS="\t";{ print $1,$2,$3,$4,$5,$6,$7,$8,"ID="NR";""Name="$9}}' > chr${i}.ncbi.gff.tmp
cat ./chr${i}.header chr${i}.ncbi.gff.tmp > chr${i}.bpseq.ncbi.gff
bp_seqfeature_load.pl -f -d ${var1} chr${i}.bpseq.ncbi.gff chr${i}.fa && rm *.tmp
}

Ensemble () {
cat chr${i}.gff.bed.tmp | sed '{s/,/|/g}' | sed '{s/SNP/Ensemble/g}' | awk '{OFS="\t";FS="\t";{ print $1,$2,$3,$4,$5,$6,$7,$8,"ID="NR";""Name="$9}}' > chr${i}.Ensemble.gff.tmp
cat ./chr${i}.header chr${i}.Ensemble.gff.tmp > chr${i}.bpseq.Ensemble.gff
bp_seqfeature_load.pl -f -d ${var1} chr${i}.bpseq.Ensemble.gff chr${i}.fa && rm *.tmp
}

NCBI2 (){

cat "$var3" | awk '{OFS="\t";FS="\t";{ print $1,$2-1,$3,$11,$12 }}' | sed {1d} | sed '{s/^/chr/g}' > dummy.temp.bed

}

Ensemble2 () {
cat "$var3" | awk '{OFS="\t";FS="\t";{ print $1,$2-1,$3,$16,$12 }}' | sed {1d} | sed '{s/^/chr/g}' > dummy.temp.bed
}

${var2}2

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y;
do
cat $1 | grep -v '#' | sed '{s/^/chr/g}' | sed '{s/NEGATIVE_TRAIN_SITE;//g}' | sed '{s/POSITIVE_TRAIN_SITE;//g}' | grep -w chr${i} | cut -f1-8 > chr${i}.tmp
awk '{OFS="\t";FS="\t"; if (!/^#/){print $1,".","SNP",$2,$2,$6,"+",".","ID=HYEX"NR";""Name=HYEX"NR";""Note="$4">"$5";"substr($0, index($0,$8))}}' chr${i}.tmp > chr${i}.gff.tmp
gff2bed < chr${i}.gff.tmp > chr${i}.gff.bed
/BiO/ycparkworking/b.software/bedtools2/bin/bedtools intersect -u -a dummy.temp.bed -b chr${i}.gff.bed > chr${i}.db.bed.tmp
cut -f1-8 chr${i}.gff.tmp > chr${i}.gff.tmp.row.tmp
cut -f4 chr${i}.db.bed.tmp > chr${i}.db.bed.row.tmp
paste chr${i}.gff.tmp.row.tmp chr${i}.db.bed.row.tmp > chr${i}.gff.bed.tmp
$var2
done
