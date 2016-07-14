# CSR-to-GeoNetwok
XSLT to transform Cruise Summary Report (CSR) XML metadata file into a new one to be imported in GeoNetwork

________________________________      PURPOSE AND USAGE             ________________________________________

This XSLT is a proof of concept for the transformation of the 
  Cruise Summary Report (CSR) XML metadata file to a new one focused on
  the improved visualization through the GeoNetwork 3.0.4.0 catalogue.
  
  Cruise Summary Report (CSR) are the usual means for reporting on cruises 
  or field experiments at sea. Usually, this kind of metadata are built 
  using MIKADO software under the requirements of SeaDataNet (http://www.seadatanet.org/). 
  Although the original metadata are great to distribute through the SeaDataNet portal, 
  is not adequate at all to be incorporated into the GeoNetwork catalogue.
  
  Usability is under the scope of this XSLT.

  As such, this XSLT must be considered as unstable, and can be updated any
  time based on the revisions to the ISO19115/ISO19139/SeaDataNet specifications 
  and to the particular requirements of the Instituto Español de Oceanografía.
  
  ________________________   MAIN TRANSFORMATION DONE BY THIS XSL ___________________________________________
  
  - Convert gmi:MI_Metadata to gmd:MD_Metadata.
  - Replace xsi:schemaLocation attribute.
  - Modify language to be complaint with ISO/TS 19139 based on code alpha-3 of ISO 639-2.
  - Convert SDN content to character string.
  - Remove sdn:additionalDocumentation and sdn:SDN_SamplingActivity.
  - Remove gmi:acquisitionInformation. A nice solution would be to change the 19139 schema plugin in GeoNetwork able to
		 detect metadata with a MI_Metadata root element. This could be achieved by modifying 
		 the schema-ident.xml file in GeoNetwork, in the <autodetect> element. After doing this, 
		 the gmi:acquisitionInformation could be kept in the metadata. If you try this solution,
		 make sure that you have changed the root element to <gmi:MI_Metadata> and that xsi:schemaLocation
		 has been removed. Good luck!
  - Convert sdn:SDN_DataIdentification to gmd:MD_DataIdentification.
  - Make status = completed.
  - Insert gmd:spatialRepresentationType element if not already present.
  - Detect the code of the oceanographic vessel and add a graphic overview (picture of the vessel). Pictures
    have been prevously stored in the GeoNetwork server.
  - Add links to CSR and CDI inventories with a brief explanation in both English and Spanish.
  - Distribution Format is mandatory in 19139:2005.
  - We assume that all CSR are "series" and all CDI are "dataset". By so doing, we can modify the GeoNetwork GUI to differenciate 
         both kind of resources at the home page. This will facilitate browsing CSR by the end-user.
  - Remove gmd:metadataExtensionInfo (to avoid errors in ISO validation rules).
  - Make more descriptive the title by adding at the beginning the words "Campaña/Survey: ".
  - Make more descriptive the alternate title by adding at the beginning the words "IEO referencia/identifier: ".
  - INSPIRE title and data are wrong in some CSR files.
  - Modify date to be the end of the cruise. This makes easier to find a cruise inside GeoNetwork.
  - Arrange geographic extension.
  


Authors:      Instituto Español de Oceanografía
              Pablo Otero <pablo.otero@md.ieo.es>
