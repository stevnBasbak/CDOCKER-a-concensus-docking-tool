


╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
                                                                                                                                              ║
                                                                                                                                              ║
          WELCOME TO THE PLAY ZONE                                                                                                            ║
 ****                                                                                                                                         ║
                                                                                                                                              ║
                                                                                                                                              ║
                                                                                                                                              ║
 ██████╗ █████╗ ███╗   ██╗ ██████╗███████╗███╗   ██╗ ██████╗██╗  ██╗███████╗    █████╗   █████╗  ██████╗██╗  ██╗███████╗██████╗               ║
██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝████╗  ██║██╔════╝██║  ██║██╔════╝    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗              ║
██║     ██║  ██║██╔██╗ ██║██║     █████╗  ██╔██╗ ██║██║     ██║  ██║███████╗    ██║  ██║██║  ██║██║     █████╔╝ █████╗  ██████╔╝              ║
██║     ██║  ██║██║╚██╗██║██║     ██╔══╝  ██║╚██╗██║██║     ██║  ██║╚════██║    ██║  ██║██║  ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗              ║
╚██████╗╚█████╔╝██║ ╚████║╚██████╗███████╗██║ ╚████║╚██████╗╚█████╔╝███████║    █████╔╝╝╚█████╔╝╚██████╗██║  ██╗███████╗██║  ██║              ║
 ╚═════╝ ╚════╝ ╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚════╝ ╚══════╝     ╚═══╝   ╚════╝  ╚═════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝              ║
                                                                                                                                              ║
                                                                                                                     ********                 ║
                                                                                                                                              ║
                                                                                                                                              ║
                                                                                                           Let's have some fun!               ║
                                                                                                                                              ║
                                                                                                                                              ║
╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝




README

This program enables the docking of molecules to a protein receptor in a consensus fashion, requiring minimal effort from the user. It utilizes
 two docking methods, AutoDock Vina v1.2.3 and AutoDock4, employing different search algorithms and scoring functions. Consequently, the program
 provides five distinct docking approaches for each molecule.

To run the program, ensure the following requirements are met:

Following files need to be present: codes (containing 01 to 17), ADFRsuite-1.1dev, mgltools_x86_64Linux2_1.5.7, INPUTS, docking.sh, x86_64Linux2.
Inside INPUTS you need to place the following: 1 tetxfile containing the string of smiles straight from chemdraw. The receptor (.pdbqt file) and 
the file gridsize_INPUT containing the search space for the docking (sample file can be found in the bottom)

To initiate the consensus docking, execute the docking.sh code.
Dont use stereochemistry in the chemdraw input file! Balloon cant handle that.



When running the docking.sh code, the following sequence of events will occur:

01_smiles will generate separate .smi files for each molecule present in the text file, delimited by points.
02_Comformers will generate diverse conformations for all .smi files located in ../SMILES, saving them as .mol2 files in ../COMFORMERS. The 
conformation generation is facilitated by the Balloon program, which utilizes its own generic algorithm to obtain 3D information.
03_splitter will split the compressed .mol2 files, considering that Balloon might have generated multiple conformations. The resulting files 
will be named SMILE{i}_split*.mol2.
04_transformer prepares ligands ending with split*.mol2 for docking. This step involves adding explicit hydrogens (protonation state) and 
assigning rotable bonds to account for ligand flexibility. The script converts .mol2 files to .pdbqt format.
05_gridtransformer.sh adjusts the grid coordinates outputted by Autodock tools to ensure compatibility with the docking process. Apparently, 
the grid files are not initially compatible. The new grid file is labeled as ***.
06_docking_autodockvina_vina.sh performs docking for all split conformers in ../COMFORMERS using the receptor and grid box in ../. The docking 
is carried out with AutoDock Vina v1.2.3 and employs the vina scoring function. The docked conformers and their positions in the receptor can 
be found in ../DOCKING/ADV_vina/, with output files named SMILE{i}_split*_docked.log.
07_Summerizer_ADV_vina.sh generates a summary of the created .log files in the same working directory.
08_docking_autodockvina_vinardo.sh performs docking using a different scoring function in ../DOCKING/ADV_vinardo, with output files following 
the same format as before.
09_Summerizer_ADV_vinardo.sh creates a summary in the working directory mentioned above.
10_autogrid4.sh marks the start of Autodock4 calculations. This script performs grid precalculations necessary for the docking program. It scans
 through all .pdbqt files in ../COMFORMERS, identifies unique atom types in both the receptor and ligands, and precalculates interactions between
 all atom type pairs within the specified grid box. The precalculated data is placed in one of the available AD4 search algorithms and then copied
 to all other search algorithms.
11-13 Specifiers.sh generate input parameter files (.dpf) for the different Autodock4 search algorithms (GA = Generic Algorithm, LGA = Lamarckian
 Generic Algorithm, LS = Local Search). These files define the present atom types, ligand/receptor information, grid box details, search methods,
 and other necessary parameters for Autodock4 to execute.
14_AD4_docker.sh performs the docking of all conformers using the various search methods provided by Autodock4.
15_AD4_Summerizer.sh generates a summary of all conformers docked with the AD4 method and saves it in ../DOCKING.
16_Organiser.sh merges the summaries obtained from the ADV and AD4 docking methods.
17_Data_analyser.sh conducts data analysis based on the merged file generated in the previous step.






SAMPLE FILE gridsize_INPUT
5ek0
spacing    0.372
npts       44 44 44
center    -48.776 -28.363 3.617







