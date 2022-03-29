tar -cvf - elasticAnisotropic_GBAnisotropic/.csv | pigz -9 -p 20 > elasticAnisotropic_GBAnisotropic_csv.tgz

tar -cvf - elasticAnisotropic/*.csv | pigz -9 -p 20 > elasticAnisotropic_csv.tgz

tar -cvf - anisotropicGB/*.csv | pigz -9 -p 20 > anisotropicGB_csv.tgz

# tar -jcvf isotropicGB_Period2_csv.tar.bz2 isotropicGB_Period2/*.csv