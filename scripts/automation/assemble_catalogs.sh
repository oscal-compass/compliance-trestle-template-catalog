version_tag=$1
if [ "$1" != "" ]; then 
	echo "Assembling ${catalog} with version ${version_tag}"
	trestle author catalog-assemble --markdown md_catalogs/$catalog --output $catalog --version $version_tag 
else
	echo "Assembling ${catalog}"
	trestle author catalog-assemble --markdown md_catalogs/$catalog --output $catalog
fi
