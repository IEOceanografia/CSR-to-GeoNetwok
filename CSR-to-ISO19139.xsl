<?xml version="1.0" encoding="UTF-8"?>

<!--

  Copyright 2016 Instituto Español de Oceanografía
  Licensed under GNU GPLv3
  You may not use this work except in compliance with the License.
  You may obtain a copy of the License at:
  http://www.gnu.org/licenses/gpl-3.0.txt
  
  Authors:      Instituto Español de Oceanografía
                Pablo Otero <pablo.otero@md.ieo.es>

-->

<!--

  PURPOSE AND USAGE

  This XSLT is a proof of concept for the transformation of the 
  Cruise Summary Report (CSR) XML metadata file to a new one focused on
  the improved visualization through the GeoNetwork 3.0.4.0 catalogue.
  
  Cruise Summary Report (CSR) are the usual means for reporting on cruises 
  or field experiments at sea. Usually, this kind of metadata are built 
  using MIKADO software under the requirements of SeaDataNet. Although the 
  original metadata are great to distribute through the SeaDataNet portal, 
  is not adequate at all to be incorporated into the GeoNetwork catalogue.
  
  Usability is under the scope of this XSLT.

  As such, this XSLT must be considered as unstable, and can be updated any
  time based on the revisions to the ISO19115/ISO19139/SeaDataNet specifications 
  and to the particular requirements of the Instituto Español de Oceanografía.

-->
				
<xsl:stylesheet
    xmlns:gmd    = "http://www.isotc211.org/2005/gmd"    
    xmlns:gmi    = "http://www.isotc211.org/2005/gmi"
	xmlns:sdn    = "http://www.seadatanet.org"
	xmlns:srv    = "http://www.isotc211.org/2005/srv"
	xmlns:gco    = "http://www.isotc211.org/2005/gco"
    xmlns:gts    = "http://www.isotc211.org/2005/gts"	
    xmlns:xsl    = "http://www.w3.org/1999/XSL/Transform"  
    xmlns:gmx    = "http://www.isotc211.org/2005/gmx"   
    xmlns:xsi    = "http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gml    = "http://www.opengis.net/gml"
	xmlns:geonet = "http://www.fao.org/geonetwork"
    xmlns:xlink  = "http://www.w3.org/1999/xlink"
    xmlns:ns9    = "http://inspire.ec.europa.eu/schemas/geoportal/1.0"
    xmlns:i      = "http://inspire.ec.europa.eu/schemas/common/1.0"
    xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmd/gmd.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd"
	version="1.0">

		
		<!--xmlns:schema = "http://schema.org/"-->
		
	<!-- ============================================================================= -->
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	
	<!-- Remove any white-space-only text nodes (empty lines)-->
    <xsl:strip-space elements="*"/>

	<!-- ============================================================================= -->
	

	<!--

	Mapping parameters
	==================

	This section includes mapping parameters by the XSLT processor.

	-->

	
	<xsl:param name="mTitle"><xsl:value-of select="//gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/></xsl:param>
	<!--<xsl:param name="mCode"><xsl:value-of select="substring(//gmd:citation/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString/text(),1,4)"/></xsl:param>-->
    <xsl:param name="mCode"><xsl:value-of select="//sdn:SDN_PlatformCode/@codeListValue"/></xsl:param>
 
	<xsl:param name="mWest"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/></xsl:param>
	<xsl:param name="mEast"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/></xsl:param>
	<xsl:param name="mSouth"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/></xsl:param>
	<xsl:param name="mNorth"><xsl:value-of select="//gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/></xsl:param>
	
	<xsl:param name="name_spatialRepresentationInfo">gmd:spatialRepresentationInfo</xsl:param>
    <xsl:param name="value_spatialRepresentationInfo">
		<gmd:MD_VectorSpatialRepresentation>
			  <gmd:geometricObjects>
				<gmd:MD_GeometricObjects>
				  <gmd:geometricObjectType>
					<gmd:MD_GeometricObjectTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_GeometricObjectTypeCode" codeListValue="point" />
				  </gmd:geometricObjectType>
				</gmd:MD_GeometricObjects>
			  </gmd:geometricObjects>
			</gmd:MD_VectorSpatialRepresentation>
	</xsl:param>

	
	<xsl:param name="name_referenceSystemInfo">gmd:referenceSystemInfo</xsl:param>
    <xsl:param name="value_referenceSystemInfo">		
		<gmd:MD_ReferenceSystem>
		  <gmd:referenceSystemIdentifier>
			<gmd:RS_Identifier>
			  <gmd:code>
				<gco:CharacterString>http://www.opengis.net/def/crs/EPSG/0/3041</gco:CharacterString>
			  </gmd:code>
			</gmd:RS_Identifier>
		  </gmd:referenceSystemIdentifier>
		</gmd:MD_ReferenceSystem>
	</xsl:param>
	
	<!-- URI where images of vessels are located (to add as thumbnail in GeoNetwork) -->
	<!-- 
		This part could be easily adapted by other National Oceanographic Data Center in other country. Just
        create images for each vessel (ideally with size 200x200) and store them in a accesible directory
        of your GeoNetwork server. Rename images following SeaDatanet platform codes.
    -->
	<xsl:variable name="AJuri">http://192.168.72.77:8080/geonetwork/images/buques/29AJ.jpg</xsl:variable>
	<xsl:variable name="RMuri">http://192.168.72.77:8080/geonetwork/images/buques/29RM.jpg</xsl:variable>
	<xsl:variable name="CSuri">http://192.168.72.77:8080/geonetwork/images/buques/29CS.jpg</xsl:variable>
	<xsl:variable name="FNuri">http://192.168.72.77:8080/geonetwork/images/buques/29FN.jpg</xsl:variable>
	<xsl:variable name="JNuri">http://192.168.72.77:8080/geonetwork/images/buques/29JN.jpg</xsl:variable>
	<xsl:variable name="MOuri">http://192.168.72.77:8080/geonetwork/images/buques/29MO.jpg</xsl:variable>
	<xsl:variable name="VEuri">http://192.168.72.77:8080/geonetwork/images/buques/29VE.jpg</xsl:variable>
	<xsl:variable name="EBuri">http://192.168.72.77:8080/geonetwork/images/buques/29EB.jpg</xsl:variable>
	<xsl:variable name="SOuri">http://192.168.72.77:8080/geonetwork/images/buques/29SO.jpg</xsl:variable>
	<xsl:variable name="HEuri">http://192.168.72.77:8080/geonetwork/images/buques/29HE.jpg</xsl:variable>
	<xsl:variable name="SGuri">http://192.168.72.77:8080/geonetwork/images/buques/29SG.jpg</xsl:variable>
	<xsl:variable name="XAuri">http://192.168.72.77:8080/geonetwork/images/buques/29XA.jpg</xsl:variable>
	<xsl:variable name="MYuri">http://192.168.72.77:8080/geonetwork/images/buques/29MY.jpg</xsl:variable>
	<xsl:variable name="GDuri">http://192.168.72.77:8080/geonetwork/images/buques/29GD.jpg</xsl:variable>
	<xsl:variable name="DBuri">http://192.168.72.77:8080/geonetwork/images/buques/29DB.jpg</xsl:variable>
	<xsl:variable name="JRuri">http://192.168.72.77:8080/geonetwork/images/buques/29JR.jpg</xsl:variable>
	<xsl:variable name="LUuri">http://192.168.72.77:8080/geonetwork/images/buques/29LU.jpg</xsl:variable>
	
	<!-- Add thumbnail if vessel code is found -->
	<xsl:param name="name_graphicOverview_small">gmd:graphicOverview</xsl:param>
    <xsl:param name="value_graphicOverview_small">	
        <gmd:MD_BrowseGraphic>
          <gmd:fileName>
			<xsl:if test="$mCode = '29AJ'">
			  <gco:CharacterString><xsl:value-of select="$AJuri"/></gco:CharacterString>
            </xsl:if>
			<xsl:if test="$mCode = '29RM'">
			  <gco:CharacterString><xsl:value-of select="$RMuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29CS'">
			  <gco:CharacterString><xsl:value-of select="$CSuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29FN'">
			  <gco:CharacterString><xsl:value-of select="$FNuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29JN'">
			  <gco:CharacterString><xsl:value-of select="$JNuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29MO'">
			  <gco:CharacterString><xsl:value-of select="$MOuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29VE'">
			  <gco:CharacterString><xsl:value-of select="$VEuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29EB'">
			  <gco:CharacterString><xsl:value-of select="$EBuri"/></gco:CharacterString>
            </xsl:if> 
			<xsl:if test="$mCode = '29SO'">
			  <gco:CharacterString><xsl:value-of select="$SOuri"/></gco:CharacterString>
            </xsl:if>
			<xsl:if test="$mCode = '29HE'">
			  <gco:CharacterString><xsl:value-of select="$HEuri"/></gco:CharacterString>
            </xsl:if>
            <xsl:if test="$mCode = '29SG'">
			  <gco:CharacterString><xsl:value-of select="$SGuri"/></gco:CharacterString>
            </xsl:if>
            <xsl:if test="$mCode = '29XA'">
			  <gco:CharacterString><xsl:value-of select="$XAuri"/></gco:CharacterString>
            </xsl:if>
            <xsl:if test="$mCode = '29MY'">
			  <gco:CharacterString><xsl:value-of select="$MYuri"/></gco:CharacterString>
            </xsl:if>
            <xsl:if test="$mCode = '29GD'">
			  <gco:CharacterString><xsl:value-of select="$GDuri"/></gco:CharacterString>
            </xsl:if>
            <xsl:if test="$mCode = '29JR'">
			  <gco:CharacterString><xsl:value-of select="$JRuri"/></gco:CharacterString>
            </xsl:if>
            <xsl:if test="$mCode = '29LU'">
			  <gco:CharacterString><xsl:value-of select="$LUuri"/></gco:CharacterString>
            </xsl:if>  			
          </gmd:fileName>
          <gmd:fileDescription>
            <gco:CharacterString>thumbnail</gco:CharacterString>
          </gmd:fileDescription>
          <gmd:fileType>
            <gco:CharacterString>jpg</gco:CharacterString>
          </gmd:fileType>
        </gmd:MD_BrowseGraphic>
	</xsl:param>

	
	<xsl:param name="distribution_info">
		<gmd:MD_Distribution>
		
		    <!-- Distribution Format is mandatory in 19139:2005 -->
		    <gmd:distributionFormat>
				<gmd:MD_Format>
					<gmd:name>
						<gco:CharacterString>Unknown</gco:CharacterString>
					</gmd:name>
					<gmd:version>
						<gco:CharacterString>Unknown</gco:CharacterString>
					</gmd:version>
				</gmd:MD_Format>
			</gmd:distributionFormat>
			
			<!-- Add links to CSR and CDI inventories with a brief explanation in both English and Spanish (keep end-users in mind!) -->
			<gmd:transferOptions>
				<gmd:MD_DigitalTransferOptions>
				  <gmd:onLine>
					<gmd:CI_OnlineResource>
					  <gmd:linkage>
						<gmd:URL>http://seadata.bsh.de/csr/retrieve/sdn2_index.html</gmd:URL>
					  </gmd:linkage>
					  <gmd:protocol>
						<gco:CharacterString>WWW:LINK-1.0-http--related</gco:CharacterString>
					  </gmd:protocol>
					  <gmd:name>
						<gco:CharacterString>Base de datos internacional con información de más de 53.000 campañas desde 1873 hasta la actualidad. La presente campaña la podrás encontrar como <xsl:value-of select="$mTitle"/>. | &#xD;&#xA; 
											 International database with information of more than 53.000 surveys from 1873 till today. Use the tag <xsl:value-of select="$mTitle"/> to locate the present survey.</gco:CharacterString>
					  </gmd:name>
					  <gmd:description>
						<gco:CharacterString>SeaDataNet - CRS inventory</gco:CharacterString>
					  </gmd:description>
					</gmd:CI_OnlineResource>
				  </gmd:onLine>
				  <gmd:onLine>
					<gmd:CI_OnlineResource>
					  <gmd:linkage>
						<gmd:URL>http://seadatanet.maris2.nl/v_cdi_v3/search.asp</gmd:URL>
					  </gmd:linkage>
					  <gmd:protocol>
						<gco:CharacterString>WWW:LINK-1.0-http--related</gco:CharacterString>
					  </gmd:protocol>
					  <gmd:name>
						<gco:CharacterString>Descubre si hay datos de esta campaña disponibles, utilizando para ello la etiqueta <xsl:value-of select="$mTitle"/> en el buscador de datos de SeaDataNet. | &#xD;&#xA; 
											 Discover if there are avialable data associated to this cruise by using the tag <xsl:value-of select="$mTitle"/> in the free search box of the SeaDataNet portal.</gco:CharacterString>
					  </gmd:name>
					  <gmd:description>
						<gco:CharacterString>SeaDataNet - CDI inventory</gco:CharacterString>
					  </gmd:description>
					</gmd:CI_OnlineResource>
				  </gmd:onLine>
				</gmd:MD_DigitalTransferOptions>
			</gmd:transferOptions>
		</gmd:MD_Distribution>
	</xsl:param>
		
	
	<!--

	Apply templates
	===============

	-->
	
	<!--Modify language to be complaint with ISO/TS 19139 based on code alpha-3 of ISO 639-2-->
	<xsl:template match="//gmd:language">
		<gmd:language>
			<gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/" codeListValue="eng">eng</gmd:LanguageCode>
		</gmd:language>
	</xsl:template>
	
    <!-- Convert SDN content to character string -->
    <xsl:template
        match="sdn:SDN_EDMOCode|sdn:SDN_CountryCode|sdn:SDN_PortCode|sdn:SDN_CRSCode|
        sdn:SDN_PlatformCode|sdn:SDN_PlatformCategoryCode|sdn:SDN_EDMERPCode|
        sdn:SDN_WaterBodyCode|sdn:SDN_MarsdenCode|sdn:SDN_ParameterDiscoveryCode|
        sdn:SDN_DeviceCategoryCode|sdn:SDN_DataCategoryCode|sdn:SDN_HierarchyLevelNameCode|
        sdn:SDN_FormatNameCode">
        <gco:CharacterString>
            <xsl:value-of select="text()"/>
        </gco:CharacterString>
    </xsl:template>

    <!-- Remove sdn:additionalDocumentation and sdn:SDN_SamplingActivity -->	
    <xsl:template match="sdn:additionalDocumentation|sdn:SDN_SamplingActivity"/>
	
	<!-- Remove gmi:acquisitionInformation -->
	<!--
		 A nice solution would be to change the 19139 schema plugin in GeoNetwork able to
		 detect metadata with a MI_Metadata root element. This could be achieved by modifying 
		 the schema-ident.xml file in GeoNetwork, in the <autodetect> element. After doing this, 
		 the gmi:acquisitionInformation could be kept in the metadata. If you try this solution,
		 make sure that you have changed the root element to <gmi:MI_Metadata> and that xsi:schemaLocation
		 has been removed. Good luck!
	-->
	<xsl:template match="gmi:acquisitionInformation"/>
	
    <!-- Convert to data identification and add gmd:spatialRepresentationType-->
    <xsl:template match="sdn:SDN_DataIdentification">
        <gmd:MD_DataIdentification>
		
            <xsl:apply-templates select="gmd:citation"/>
			<xsl:apply-templates select="gmd:abstract"/>
			
			<!-- Make status = completed -->
			<xsl:if test="not(//gmd:status)">
				<gmd:status>
					<gmd:MD_ProgressCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_ProgressCode" codeListValue="completed" />
				</gmd:status>
			</xsl:if>
			
			<xsl:apply-templates select="gmd:pointOfContact"/>
			
			<!-- Insert picture if not already present -->
			<!-- <xsl:if test="not(//gmd:graphicOverview) and ($mCode = '29CS' or $mCode = '29RM' or $mCode = '29AJ' or $mCode = '29FN' or $mCode = '29JN' or $mCode = '29MO' or $mCode = '29VE' or $mCode = '29EB' or $mCode = '29SO')">
				<xsl:element name="{$name_graphicOverview_small}"><xsl:copy-of select="$value_graphicOverview_small" /></xsl:element>
			</xsl:if> -->
			
			<xsl:if test="($mCode = '29CS' or $mCode = '29RM' or $mCode = '29AJ' or $mCode = '29FN' or $mCode = '29JN' or $mCode = '29MO' or $mCode = '29VE' or $mCode = '29EB' or $mCode = '29SO' or $mCode = '29HE' or $mCode = '29SG' or $mCode = '29XA' or $mCode = '29MY' or $mCode = '29GD' or $mCode = '29JR' or $mCode = '29LU')">
				<xsl:element name="{$name_graphicOverview_small}"><xsl:copy-of select="$value_graphicOverview_small" /></xsl:element>
			</xsl:if>
			
			<xsl:if test="gmd:graphicOverview">
				<xsl:apply-templates select="gmd:graphicOverview"/>
			</xsl:if>			
						
			<xsl:for-each select="gmd:descriptiveKeywords">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
			
			<xsl:for-each select="gmd:resourceConstraints">
				<xsl:apply-templates select="."/>
			</xsl:for-each>	
			
			<!-- Insert gmd:spatialRepresentationType element if not already present -->
			<xsl:if test="not(//gmd:spatialRepresentationType)">
				<gmd:spatialRepresentationType>
					<gmd:MD_SpatialRepresentationTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#MD_SpatialRepresentationTypeCode"
                                                  codeListValue="vector"/>
				</gmd:spatialRepresentationType>
			</xsl:if>
			
			<!-- Insert "campaign" as type of "initiative" -->
			<!--
			<gmd:aggregationInfo>
				<gmd:MD_AggregateInformation>
					<gmd:initiativeType>
						<gmd:DS_InitiativeTypeCode codeListValue="campaign" codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#DS_InitiativeTypeCode" codeSpace="ISOTC211/19115">Campaña/Survey</gmd:DS_InitiativeTypeCode>
					</gmd:initiativeType>
				</gmd:MD_AggregateInformation>
			</gmd:aggregationInfo>
			-->
			
			<xsl:apply-templates select="gmd:language"/>
			<xsl:apply-templates select="gmd:characterSet"/>
			<xsl:apply-templates select="gmd:topicCategory"/>
			<xsl:apply-templates select="gmd:extent"/>
						
        </gmd:MD_DataIdentification>
    </xsl:template>

	
    <!-- 
         We assume that all CSR are "series" and all CDI are "dataset". By so doing, we can modify the GeoNetwork GUI to differenciate 
         both kind of resources at the home page. This will facilitate browsing CSR by the end-user. 
	-->	
	<xsl:template match="gmd:hierarchyLevel/gmd:MD_ScopeCode">
        <gmd:MD_ScopeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#MD_ScopeCode" codeListValue="series" codeSpace="ISOTC211/19115">Campaña/Survey</gmd:MD_ScopeCode>
        <xsl:apply-templates select="*"/>   
    </xsl:template>
	
	<xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode">
		<gmd:MD_ScopeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#MD_ScopeCode" codeListValue="series" codeSpace="ISOTC211/19115">Campaña/Survey</gmd:MD_ScopeCode>
		<xsl:apply-templates select="*"/>   
    </xsl:template>
	
	<!-- Remove gmd:metadataExtensionInfo (to avoid errors in ISO validation rules ) -->
	<xsl:template match="gmd:metadataExtensionInfo"/>
	
	<!-- Remove gmd:hierarchyLevelName -->
	<!--<xsl:template match="gmd:hierarchyLevelName"/>-->
	
    <!-- Make more descriptive the title by adding at the beginning the words "Campaña/Survey: "-->	
	<xsl:template match="//gmd:citation/gmd:CI_Citation/gmd:title">
        <gmd:title>
            <gco:CharacterString>Campaña/Survey: <xsl:copy-of select="$mTitle" /></gco:CharacterString>
        </gmd:title>	        
    </xsl:template>
	
	<!-- Make more descriptive the alternate title -->
    <xsl:param name="mAltTitle">
      <xsl:value-of select="//gmd:citation/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString"/>
    </xsl:param>	
	<xsl:template match="//gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
        <gmd:alternateTitle>
            <gco:CharacterString>IEO referencia/identifier: <xsl:copy-of select="$mAltTitle" /></gco:CharacterString>
        </gmd:alternateTitle>	        
    </xsl:template>
	
	<!-- INSPIRE title and data are wrong in some CSR files. -->
	<xsl:template match="//gmd:specification/gmd:CI_Citation/gmd:date"/>
	<xsl:template match="//gmd:specification/gmd:CI_Citation/gmd:title">      
	    <gmd:title>
			<gco:CharacterString>Commission Regulation (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services</gco:CharacterString>
	    </gmd:title>
	    <gmd:date>
			<gmd:CI_Date>
				<gmd:date>
					<gco:Date>2010-12-08</gco:Date>
				</gmd:date>
				<gmd:dateType>
					<gmd:CI_DateTypeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#CI_DateTypeCode" codeListValue="publication" codeSpace="ISOTC211/19115">publication</gmd:CI_DateTypeCode>
				</gmd:dateType>
			</gmd:CI_Date>
	    </gmd:date>
	</xsl:template>	
	
	<!-- Modify date to be the end of the cruise. This makes easier to find a cruise inside GeoNetwork -->
	<xsl:template match="//gmd:citation/gmd:CI_Citation/gmd:date">
	    <gmd:date>
            <gmd:CI_Date>
                <gmd:date>
                    <gco:Date><xsl:value-of select="substring(//gmi:acquisitionInformation/gmi:MI_AcquisitionInformation/gmi:operation/gmi:MI_Operation/gmi:significantEvent[last()]/gmi:MI_Event/gmi:time/gco:DateTime[last()]/text(),1,10)"/></gco:Date>
                </gmd:date>
                <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="http://vocab.nerc.ac.uk/isoCodelists/sdnCodelists/gmxCodeLists.xml#CI_DateTypeCode"  codeListValue="creation"  codeSpace="ISOTC211/19115" >creation</gmd:CI_DateTypeCode>
                </gmd:dateType>
            </gmd:CI_Date>
        </gmd:date>
	</xsl:template>
	

	<!-- Arrange geographic extension
	
		 Delete other existent geographic elements, as for example, GML information from the track cruise, 
	     but keek those related to the bounding box. Note that from GeoNetwork 3.0.1 multiple geographic
		 boundary boxes are permitted.
		 
		 Moreover, GeoNetwork (at least v3.0.4) fails in the 
		 spatial extent representation if any of the coordinates is "0". We check and add some decimals 
		 if neccesary. 
		 -->
	<xsl:template match="//gmd:extent/gmd:EX_Extent">
		<gmd:EX_Extent>
		    <xsl:for-each select="gmd:geographicElement">
			   <xsl:if test="gmd:EX_GeographicBoundingBox">
				<gmd:geographicElement>
					<gmd:EX_GeographicBoundingBox>				
						<gmd:westBoundLongitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/></gco:Decimal>
							</xsl:if>
						</gmd:westBoundLongitude>
						<gmd:eastBoundLongitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/></gco:Decimal>
							</xsl:if>
						</gmd:eastBoundLongitude>
						<gmd:southBoundLatitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/></gco:Decimal>
							</xsl:if>
						</gmd:southBoundLatitude>
						<gmd:northBoundLatitude>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal = 0">
								<gco:Decimal>0.001</gco:Decimal>
							</xsl:if>
							<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal != 0">
								<gco:Decimal><xsl:value-of select="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/></gco:Decimal>
							</xsl:if>
						</gmd:northBoundLatitude>
					</gmd:EX_GeographicBoundingBox>
				</gmd:geographicElement>	
               </xsl:if>				
			</xsl:for-each>
			<xsl:apply-templates select="gmd:temporalElement"/>
		</gmd:EX_Extent>			
	</xsl:template>
	
	
	<!-- Convert gmi:MI_Metadata to gmd:MD_Metadata -->
	<!-- Note that child nodes must be in order -->
	<xsl:template match="gmi:MI_Metadata">	    
        <gmd:MD_Metadata>
		
		    <!-- Explicity copy the schemaLocation --> 
            <xsl:copy-of select="document('')/*/@xsi:schemaLocation"/>
			
            <!--<xsl:apply-templates select="*"/>-->			
			<xsl:apply-templates select="@*|node()[not(self::gmd:dataQualityInfo)]"/>
											
			<!--
			<xsl:if test="not(//gmd:spatialRepresentationInfo)">
				<xsl:element name="{$name_spatialRepresentationInfo}"><xsl:copy-of select="$value_spatialRepresentationInfo" /></xsl:element>
			</xsl:if>
			<xsl:if test="not(//gmd:referenceSystemInfo)">
				<xsl:element name="{$name_referenceSystemInfo}"><xsl:copy-of select="$value_referenceSystemInfo" /></xsl:element>
			</xsl:if>
			-->
			
			<xsl:if test="not(//gmd:distributionInfo/gmd:transferOptions)">
			    <gmd:distributionInfo xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:date="http://exslt.org/dates-and-times">
					<xsl:copy-of select="$distribution_info" />
				</gmd:distributionInfo>
			</xsl:if>
			
			<xsl:apply-templates select="gmd:dataQualityInfo"/>
					
        </gmd:MD_Metadata>
    </xsl:template>
		
	<!-- Apply templates (master) -->	
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>			
        </xsl:copy>		
    </xsl:template>
	
	<!-- replace xsi:schemaLocation attribute -->
    <xsl:template match="@xsi:schemaLocation">
		<xsl:attribute name="xsi:schemaLocation">http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmd/gmd.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd</xsl:attribute>
    </xsl:template>
	
</xsl:stylesheet>