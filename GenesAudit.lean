import BioCore.Library.Genes.Chain
import BioCore.Library.Genes.Pack
open BioCore BioCore.Genes
/-! Axioms audit of every hand-written theorem of the gene library (track gn). -/
#print axioms Chain.INS.transcription
#print axioms Chain.INS.decoding
#print axioms Chain.INS.rna_balanced
#print axioms Chain.INS.protein_balanced
#print axioms Chain.INS.chain
#print axioms Chain.TP53.transcription
#print axioms Chain.TP53.decoding
#print axioms Chain.TP53.rna_balanced
#print axioms Chain.TP53.protein_balanced
#print axioms Chain.TP53.chain
#print axioms Chain.BRCA1.transcription
#print axioms Chain.BRCA1.decoding
#print axioms Chain.BRCA1.rna_balanced
#print axioms Chain.BRCA1.protein_balanced
#print axioms Chain.BRCA1.chain
#print axioms Chain.INS.not_TP53
#print axioms unpackDNAAux_length
#print axioms unpackDNA_length
#print axioms unpackAAAux_length
#print axioms unpackAA_length
