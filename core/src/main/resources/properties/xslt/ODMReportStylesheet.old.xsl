<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Copyright (C) 2010, Akaza Research, LLC.  -->
<xsl:stylesheet version="2.0" xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3c.org/2001/XMLSchema-instance" xmlns:def="http://www.cdisc.org/ns/def/v1.0" xmlns:xlink="http://www.w3c.org/1999/xlink" xmlns:OpenClinica="http://www.openclinica.org/ns/openclinica_odm/v1.3" xmlns:fn="http://www.w3.org/2005/02/xpath-functions">
	<xsl:output method="text" version="4.0" encoding="utf-8" indent="no"/>
	<!-- ****************************************************************************************************** -->
	<!-- File: ODMReportStylesheet.xsl -->
	<!-- Date: 2010-03-15 -->
	<!-- Version: 1.0.0 -->
	<!-- Author: Pradnya Gawade (Akaza) -->
	<!-- Organization: Akaza Research -->
	<!-- Description: A style sheet for transforming CDISC ODM XML data into table-based data format. -->
	<!-- Notes:  none yet	-->
	<!-- Source Location:  SVN repository  -->
	<!-- Release Notes for version 1.0.0: -->
	<!--   1. TBD	-->
	<!-- ****************************************************************************************************** -->
	<xsl:variable name="language">
		<xsl:text>en</xsl:text>
	</xsl:variable>
	<!-- Global variables -->
	<xsl:variable name="crf-status-summary-table-name" select="'crf_status_summary'"/>
	<!-- event status values -->
	<xsl:variable name="eventStatusDataEntryStarted" select="'data entry started'"/>
	<xsl:variable name="eventStatusCompleted" select="'completed'"/>
	<xsl:variable name="eventStatusSigned" select="'signed'"/>
	<xsl:variable name="eventStatusSkipped" select="'skipped'"/>
	<xsl:variable name="eventStatusStopped" select="'stopped'"/>
	<xsl:variable name="eventStatusLocked" select="'locked'"/>
	<!-- crf status values -->
	<xsl:variable name="crfStatusInitialDataEntryStarted" select="'initial data entry'"/>
	<xsl:variable name="crfStatusDoubleDataEntryStarted" select="'double data entry'"/>
	<xsl:variable name="crfStatusCompleted" select="'data entry complete'"/>
	<xsl:variable name="crfStatusLocked" select="'locked'"/>
	<xsl:variable name="crfStatusInitialDataEntryCompleted" select="'initial data entry complete'"/>
	<xsl:template match="/">
		<!-- <xsl:call-template name="TOC"/>
		<xsl:call-template name="FormMetadataList"/>
		<xsl:call-template name="MeasurementUnitMetadataList"/>
		<xsl:call-template name="CodeListMetadataList"/> -->
		<xsl:call-template name="FormData"/>
	</xsl:template>
	<xsl:template name="FormData">
		<xsl:variable name="now" select="current-dateTime()"/>
		<!-- <xsl:for-each select="/odm:ODM/odm:Study"> -->
		<!-- *********** study start ***************  -->
		<xsl:variable name="formNameNVersionSeparator" select="'-'"/>
		<xsl:variable name="FileOID" select="/odm:ODM/@FileOID"/>
		<xsl:variable name="Study" select="/odm:ODM/odm:Study[1]"/>
		<xsl:variable name="studyOID" select="$Study/@OID"/>
		<xsl:variable name="protocolNameStudy" select="$Study/odm:GlobalVariables/odm:ProtocolName"/>
		<!-- 04/12/2010 Changed the study schema name to have Protocol name instead of study OID, appended with data set name -->
		<xsl:variable name="studySchemaName">
			<xsl:call-template name="schema-name-for-study">
				<xsl:with-param name="studyProtocolName" select="$protocolNameStudy"/>
				<xsl:with-param name="FileOID" select="$FileOID"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="drop-schema-for-study">
			<xsl:with-param name="schema-name" select="$studySchemaName"/>
		</xsl:call-template>
		<xsl:call-template name="create-schema_for_study">
			<xsl:with-param name="schema-name" select="$studySchemaName"/>
		</xsl:call-template>
		<!--****************** Create and insert data into table for study subject listing ***************** -->
		<xsl:call-template name="create-table-study-subject-listing">
			<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
		</xsl:call-template>
		<!-- *********** CREATE TABLE for Study Subject Listing end ***************  -->
		<!-- *********** INSERT DATA into  Study Subject Listing TABLE start ***************  -->
		<!-- get Subject records for initial listing -->
		<!-- THIS SHOULD BE REWRITTEN, will not scale to large datasets due to nested loops -->
		<!-- investigate using Muenchian Method - see  http://www.jenitennison.com/xslt/grouping/muenchian.html and 	
			http://ewbi.blogs.com/develops/2005/02/crosstabs_of_xm.html -->
		<!-- and/or preprocessing of the ODM - see http://www.xmldatabases.org/WK/blog/1086?t=item and 
			http://www.movable-type.co.uk/scripts/itunes-albumlist.html -->
		<xsl:for-each select="/odm:ODM/odm:ClinicalData">
			<!-- get subject site information 
				Get the 'Study' element matching its 'OID' value with that of 'StudyOID' attribute value of the 'ClinicalData' element inside which the subject data resides in the ODM xml file.
				Inside the above fetched 'Study' element get the site name as: Portion after <space><dash><space> in the value of [Study -> GlobalVariables -> StudyName]
				Inside the above fetched 'Study' element get the site id as: Portion after <space><dash><space> in the value of [Study -> GlobalVariables -> ProtocolName]
				-->
			<xsl:variable name="siteOID" select="@StudyOID"/>
			<xsl:variable name="siteStudyElement" select="/odm:ODM/odm:Study[@OID = $siteOID]"/>
			<!--<xsl:if test="$siteStudyElement">-->
			<xsl:variable name="protocolName" select="$siteStudyElement/odm:GlobalVariables/odm:ProtocolName"/>
			<xsl:variable name="studyName" select="$siteStudyElement/odm:GlobalVariables/odm:StudyName"/>
			<xsl:variable name="spaceDashSpace" select="'&#x20;-&#x20;'"/>
			<xsl:variable name="siteProtocolName">
				<xsl:value-of select="substring-after($protocolName,$spaceDashSpace)"/>
			</xsl:variable>
			<xsl:variable name="siteName">
				<xsl:value-of select="substring-after($studyName,$spaceDashSpace)"/>
			</xsl:variable>
			<!--</xsl:if>	-->
			<!--<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData">-->
			<xsl:for-each select="./odm:SubjectData">
				<!--xsl:variable name="subjectData" select="./odm:SubjectData"/>-->
				<xsl:variable name="ssoid" select="@SubjectKey"/>
				<xsl:variable name="ssid" select="@OpenClinica:StudySubjectId"/>
				<xsl:variable name="subject_status" select="@OpenClinica:Status"/>
				<xsl:variable name="subject_unique_id" select="@OpenClinica:UniqueIdentifier"/>
				<xsl:variable name="secondary_id"/>
				<xsl:variable name="date_of_birth" select="@OpenClinica:DateOfBirth"/>
				<xsl:variable name="sex" select="@OpenClinica:Sex"/>				
					
					insert into <xsl:value-of select="$studySchemaName"/>.study_subject_listing (
					ssoid, ssid
					<xsl:if test="$subject_status">, subject_status</xsl:if>
				<xsl:if test="$subject_unique_id">, subject_unique_id</xsl:if>
				<xsl:if test="$secondary_id">, secondary_id</xsl:if>
				<xsl:if test="$date_of_birth">, date_of_birth</xsl:if>
				<xsl:if test="$sex">, sex</xsl:if>
				<xsl:if test="$siteProtocolName">, site_protocol_name</xsl:if>
				<xsl:if test="$siteName">, site_name</xsl:if>,
					warehouse_insert_created_timestamp
					) values (	
					'<xsl:value-of select="$ssoid"/>',		
					'<xsl:value-of select="$ssid"/>'
					<xsl:if test="$subject_status">, '<xsl:value-of select="$subject_status"/>'</xsl:if>
				<xsl:if test="$subject_unique_id">, '<xsl:value-of select="$subject_unique_id"/>'</xsl:if>
				<xsl:if test="$secondary_id">, '<xsl:value-of select="$secondary_id"/>'</xsl:if>
				<xsl:if test="$date_of_birth">, '<xsl:value-of select="$date_of_birth"/>'</xsl:if>
				<xsl:if test="$sex">, '<xsl:value-of select="$sex"/>'</xsl:if>
				<xsl:if test="$siteProtocolName">, '<xsl:call-template name="escape-special-sql-chars">
						<xsl:with-param name="dataValue" select="$siteProtocolName"/>
					</xsl:call-template>'
					</xsl:if>
				<xsl:if test="$siteName">, '<xsl:call-template name="escape-special-sql-chars">
						<xsl:with-param name="dataValue" select="$siteName"/>
					</xsl:call-template>'
					</xsl:if>
					,'<xsl:value-of select="$now"/>'
					);
				</xsl:for-each>
		</xsl:for-each>
		<!-- *********** INSERT DATA into  Study Subject Listing TABLE end ***************  -->
		<!-- ********************* Create table for crf versions ********************** -->
		<!-- CREATE CRF versions table start -->
		<xsl:call-template name="create-table-crf-version">
			<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
		</xsl:call-template>
		
		<!-- CREATE CRF versions table end -->
		<!-- CREATE CRF STATUS SUMMARY TABLE START -->
		<xsl:call-template name="create-crf-status-summary-table">
			<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
			<!--<xsl:with-param name="crf-status-summary-table-name" select="$crf-status-summary-table-name"/>-->
		</xsl:call-template>
		<!-- @pgawade 07/21/2010 Added the foreign key constaraint for ssid, ssoid on the crf_status_summary table -->
		<!-- @tbh 09/22/2010 temp removed while looking for a fix -->
		<!--
		<xsl:call-template name="create-foreign-key-ssoid-ssid">
			<xsl:with-param name="tableNameWithoutSchema" select="'crf_status_summary'"/>
			<xsl:with-param name="study-schema-name"  select="$studySchemaName"/>
		</xsl:call-template>
		-->
		<!-- CREATE CRF STATUS SUMMARY TABLE END -->
		<!-- *************** Create and insert data into case report form tables *************************** -->
		<!-- Form Data Tables 	
			get list of forms and groups
			create one table per form, plus sub-table for each repeating group in a form 
			each item should be a column in the form/group table -->
		<xsl:for-each select="$Study/odm:MetaDataVersion/odm:FormDef">
			<!-- *********** form definition start 
					***************  -->
			<!-- ********* form definition start ********* -->
			<xsl:variable name="formVersionOID" select="@OID"/>
			<!-- *******  formVersionOID <xsl:value-of select="normalize-space($formVersionOID)"></xsl:value-of>	****** -->
			<xsl:variable name="formVersionName" select="@Name"/>
			<!-- ******** formVersionName <xsl:value-of select="normalize-space($formVersionName)"></xsl:value-of> ******** -->
			<!-- calculate the parent CRF OID until parent CRF OID is dumped into this xml by OC team -->
			<xsl:variable name="pFormNameFromVersion" select="substring-before($formVersionName,$formNameNVersionSeparator)">
			</xsl:variable>
			<xsl:variable name="formVersion" select="substring-after($formVersionName,$formNameNVersionSeparator)"/>
			<!--	<xsl:variable name="prevFormDefName" select="preceding-sibling::FormDef[1]/@Name" />-->
			<xsl:variable name="positionIndex">
				<xsl:value-of select="position()"/>
			</xsl:variable>
			<xsl:variable name="one">1</xsl:variable>
			<xsl:variable name="prevIndex">
				<xsl:value-of select="$positionIndex - $one"/>
			</xsl:variable>
			<xsl:variable name="prevFormDef" select="../odm:FormDef[position()=$prevIndex]"/>
			<xsl:variable name="prevFormName">
				<xsl:value-of select="substring-before($prevFormDef/@Name,$formNameNVersionSeparator)"/>
			</xsl:variable>
			<!-- get all previous form version for the same CRF -->
			<xsl:variable name="prevFormDefs" select="../odm:FormDef[position()&lt;$positionIndex]"/>
			<xsl:variable name="prevSameFormDefs" select="$prevFormDefs[substring-before(@Name,$formNameNVersionSeparator) = $pFormNameFromVersion]"/>
			<!-- INSERT the data into crf_version table start-->
					insert into <xsl:value-of select="$studySchemaName"/>.crf_version (crf_name, crf_version_name, warehouse_insert_created_timestamp) values 
					( '<xsl:value-of select="normalize-space($pFormNameFromVersion)"/>', 
					'<xsl:value-of select="normalize-space($formVersion)"/>',
					'<xsl:value-of select="$now"/>');
			<!-- INSERT the data into crf_version table end> -->
			<!-- Insert data into crf_status_summary table -->
			<xsl:call-template name="collect-and-insert-data-into-crf-status-summary-table">
				<xsl:with-param name="formVersionOID" select="$formVersionOID"/>
				<xsl:with-param name="formVersion" select="$formVersion"/>
				<xsl:with-param name="crfName" select="$pFormNameFromVersion"/>
				<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
				<xsl:with-param name="now" select="$now"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="normalize-space($pFormNameFromVersion) = normalize-space($prevFormName)">
					<!-- version of same CRF  -->
					<xsl:for-each select="./odm:ItemGroupRef">
						<!-- *********** group start ***************  -->
						<xsl:variable name="itemGroupRefOID" select="@ItemGroupOID"/>
						<xsl:variable name="itemGroupDef" select="../../odm:ItemGroupDef[@OID=$itemGroupRefOID]"/>
						<xsl:variable name="groupName" select="$itemGroupDef/@Name"/>
						<xsl:choose>
							<xsl:when test="$itemGroupDef/@Repeating = 'No'">
								<!-- *********** Non-repeating group  ***************  -->
								<xsl:variable name="tableName">
									<xsl:call-template name="table-name-non-repeating-grp-items">
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
										<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
									</xsl:call-template>
								</xsl:variable>
								<!--<xsl:variable name="precedingFormNonGroupedCnt" select="count($prevFormDef/odm:ItemGroupRef[@ItemGroupOID = 
								../../odm:ItemGroupDef[@Repeating='No']/@OID])"/>-->
								<xsl:variable name="precedingSameFormsNonGroupedCnt" select="count($prevSameFormDefs/odm:ItemGroupRef[@ItemGroupOID = 
								../../odm:ItemGroupDef[@Repeating='No']/@OID])"/>
								<xsl:if test="$precedingSameFormsNonGroupedCnt = 0">
									<!-- Table for non-grouped items was not created before; create it -->
									<!-- *********** CREATE TABLE for non-repeating items start ***************  -->
									<xsl:call-template name="create-table-non-repeating-grp-items">
										<xsl:with-param name="tableName" select="$tableName"/>
										<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
									</xsl:call-template>
									<xsl:call-template name="create-primary-key-non-repeating-grp-items">
										<xsl:with-param name="tableName" select="$tableName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
									</xsl:call-template>
									<xsl:call-template name="create-foreign-key-non-repeating-grp-items">
										<xsl:with-param name="tableName" select="$tableName"/>
										<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
									</xsl:call-template>								
									
									<!-- *********** CREATE TABLE or non-repeating items end ***************  -->
								</xsl:if>
								<xsl:if test="$precedingSameFormsNonGroupedCnt > 0">
									<!-- *************** Table for non-grouped items is already created; add the columns for newly added items start ********** -->
									<xsl:variable name="precedingUnGroupedItemGroup" select="$prevFormDef/odm:ItemGroupRef[@ItemGroupOID = 
									../../odm:ItemGroupDef[@Repeating='No']/@OID]"/>
									<xsl:variable name="precedingUnGroupedItemGroupDef" select="
									../../odm:ItemGroupDef[@OID=$precedingUnGroupedItemGroup/@ItemGroupOID]"/>
									<xsl:for-each select="$itemGroupDef/odm:ItemRef">
										<xsl:variable name="ItemOIDval" select="@ItemOID"/>
										<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$ItemOIDval]"/>
										<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
										<!-- old code
											<xsl:variable name="itemNamePre">
												<xsl:call-template name="string-replace-all">
													<xsl:with-param name="text" select="$itemDef/@Name"/>
													<xsl:with-param name="replace" select="' '"/>
													<xsl:with-param name="by" select="'_'"/>
												</xsl:call-template>
											</xsl:variable>
											<xsl:variable name="itemName">
												<xsl:call-template name="escape-special-sql-chars">
													<xsl:with-param name="dataValue"	select="$itemNamePre"/>
												</xsl:call-template>
											</xsl:variable>-->
										<!-- new code start -->
										<xsl:variable name="itemName">
											<xsl:call-template name="clean-up-identifier">
												<xsl:with-param name="text" select="$itemDef/@Name"/>
											</xsl:call-template>
										</xsl:variable>
										<!-- new code end -->
										<xsl:variable name="isItemMultiSelect">
											<xsl:call-template name="is-item-multi-select">
												<xsl:with-param name="itemDef" select="$itemDef"/>
											</xsl:call-template>
										</xsl:variable>
										<!-- Instead of following iterate, get the count of matching item OID  -->
										<xsl:variable name="itemRepeatCnt" select="count($precedingUnGroupedItemGroupDef/odm:ItemRef[@ItemOID = $ItemOIDval])"/>
										<!-- @pgawade 06/28/2010 To fix issue #0005275, commented out the condition to check the itemRepeatCnt value before calling "add-col-to-table" function because
												 it is no more needed after updating the function "add-col-to-table" to check if column to be added already exists in the table -->
										<!--<xsl:if test="$itemRepeatCnt = 0">-->
										<!-- Item was not present in the earlier crf version. Add the column for this added item -->
										<xsl:choose>
											<xsl:when test="$itemDef/@DataType = 'partialDate'">
												<!-- For item with DataType="partialDate", create 2 columns of type date to store minimun and maximum date range values -->
												<xsl:variable name="partialDateMinValColName">
													<xsl:call-template name="partial-date-min-val-col-name">
														<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<xsl:with-param name="colName" select="$partialDateMinValColName"/>
													<xsl:with-param name="colDataType" select="'date'"/>
												</xsl:call-template>
												<xsl:variable name="partialDateMaxValColName">
													<xsl:call-template name="partial-date-max-val-col-name">
														<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<xsl:with-param name="colName" select="$partialDateMaxValColName"/>
													<xsl:with-param name="colDataType" select="'date'"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="$isItemMultiSelect='true'">
												<!-- For multi-select items create number of columns equal to number of items in the associated codelist -->
												<!-- 04/12/2010: Changes for "OpenClinica:MultiSelectListRef " child element in the definition of multi-select items -->
												<!--<xsl:variable name="codelistOID">
															<xsl:call-template name="get-codelist-OID">
																<xsl:with-param name="itemDef" select="$itemDef"/>	
															</xsl:call-template>
														</xsl:variable>-->
												<xsl:variable name="multiSelectListId">
													<xsl:call-template name="get-multi-select-list-id">
														<xsl:with-param name="itemDef" select="$itemDef"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="get-multi-select-columns-alter-table-statements">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
													<!-- removed tbh 07/26/2010 -->
													<!--<xsl:with-param name="itemName" select="$itemName"/>-->
													<!--<xsl:with-param name="codelistOID" select="$codelistOID"/>-->
													<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<!-- column name as item OID and column data type as value of attribute DataType in the item definition -->
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<!--<xsl:with-param name="colName" select="@ItemOID"/>-->
													<xsl:with-param name="colName" select="$itemName"/>
													<xsl:with-param name="colDataType" select="$itemDef/@DataType"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
										<!-- Check if the item is single select, only if the item is not multi-select -->
										<xsl:if test="$isItemMultiSelect='false'">
											<xsl:variable name="isItemSingleSelect">
												<xsl:call-template name="is-item-single-select">
													<xsl:with-param name="itemDef" select="$itemDef"/>
												</xsl:call-template>
											</xsl:variable>
											<!-- Create additional column of type text to store the label for selected value from the corresponding code list -->
											<xsl:if test="$isItemSingleSelect='true'">
												<xsl:variable name="singleSelectLabelColName">
													<xsl:call-template name="get-col-name-single-select-label">
														<!--<xsl:with-param name="itemOID" select="$ItemOIDval"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:variable name="singleSelectLabelColDataType">
													<xsl:call-template name="get-col-data-type-single-select-label"/>
												</xsl:variable>
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<xsl:with-param name="colName" select="$singleSelectLabelColName"/>
													<xsl:with-param name="colDataType" select="$singleSelectLabelColDataType"/>
												</xsl:call-template>
											</xsl:if>
										</xsl:if>
										<!--</xsl:if>-->
									</xsl:for-each>
									<!-- *************** Table for non-grouped items is already created; add the columns for newly added items end ********** -->
								</xsl:if>
								<!-- Store the non-grouped item subject data into created non-grouped items table -->
								<!-- *********** INSERT DATA INTO non-repeating items TABLE start ***************  -->
								<!-- get Subject records for non repeating data -->
								<!-- THIS SHOULD BE REWRITTEN, will not scale to large datasets due to nested loops -->
								<!-- investigate using Muenchian Method - see  http://www.jenitennison.com/xslt/grouping/muenchian.html and 	
									http://ewbi.blogs.com/develops/2005/02/crosstabs_of_xm.html -->
								<!-- and/or preprocessing of the ODM - see http://www.xmldatabases.org/WK/blog/1086?t=item and 	
								http://www.movable-type.co.uk/scripts/itunes-albumlist.html -->
								<xsl:call-template name="insert-data-non-repeating-grp-items">
									<xsl:with-param name="formVersion" select="$formVersion"/>
									<xsl:with-param name="formVersionOID" select="$formVersionOID"/>
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
									<xsl:with-param name="itemGroupRefOID" select="$itemGroupRefOID"/>
									<xsl:with-param name="now" select="$now"/>
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$itemGroupDef/@Repeating = 'Yes'">
								<!-- *********** repeating group  ***************  -->
								<!-- For repeating group items -->
								<!-- Check if the table for the repeating group present here is already created; crete the sam if not -->
								<!-- Store the repeating group items subject data into created repeating groupe items data table -->
								<xsl:variable name="tableName">
									<xsl:call-template name="table-name-repeating-grp-items">
										<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
										<xsl:with-param name="groupName" select="$groupName"/>
									</xsl:call-template>
								</xsl:variable>
								<!--<xsl:variable name="precedingFormRepeatingGroupCnt" select="count($prevFormDef/odm:ItemGroupRef[@ItemGroupOID = 
							../../odm:ItemGroupDef[@Repeating='Yes' and @Name=$groupName]/@OID])"/> -->
								<xsl:variable name="precedingSameFormsRepeatingGroupCnt" select="count($prevSameFormDefs/odm:ItemGroupRef[@ItemGroupOID = 
								../../odm:ItemGroupDef[@Repeating='Yes' and @Name=$groupName]/@OID])"/>
								<xsl:if test="$precedingSameFormsRepeatingGroupCnt = 0">
									<!-- *********** CREATE TABLE for repeating group items TABLE start ***************  -->
									<xsl:call-template name="create-table-repeating-grp-items">
										<xsl:with-param name="tableName" select="$tableName"/>
										<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
									</xsl:call-template>
									<xsl:call-template name="create-primary-key-repeating-grp-items">
										<xsl:with-param name="tableName" select="$tableName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
										<xsl:with-param name="groupName" select="$groupName"/>
									</xsl:call-template>
									<xsl:call-template name="create-foreign-key-repeating-grp-items">
										<xsl:with-param name="tableName" select="$tableName"/>
										<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
										<xsl:with-param name="groupName" select="$groupName"/>
									</xsl:call-template>
									
									<!-- *********** CREATE TABLE for repeating group items TABLE end ***************  -->
								</xsl:if>
								<xsl:if test="$precedingSameFormsRepeatingGroupCnt > 0">
									<!-- *************** Table for repeated groupe items is already created; add the columns for newly added items in this CRF version start 
							********** -->
									<xsl:variable name="precedingRepeatingGroup" select="$prevFormDef/odm:ItemGroupRef[@ItemGroupOID = 
								../../odm:ItemGroupDef[@Repeating='Yes']/@OID]"/>
									<xsl:variable name="precedingRepeatingGroupDef" select="../../odm:ItemGroupDef[@OID=$itemGroupRefOID]"/>
									<xsl:for-each select="$itemGroupDef/odm:ItemRef">
										<xsl:variable name="ItemOIDval" select="@ItemOID"/>
										<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$ItemOIDval]"/>
										<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
										<!-- old code 
								<xsl:variable name="itemNamePre">
									<xsl:call-template name="string-replace-all">
										<xsl:with-param name="text" select="$itemDef/@Name"/>
										<xsl:with-param name="replace" select="' '"/>
										<xsl:with-param name="by" select="'_'"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="itemName">
									<xsl:call-template name="escape-special-sql-chars">
										<xsl:with-param name="dataValue"	select="$itemNamePre"/>
									</xsl:call-template>
								</xsl:variable>
								-->
										<!-- new code start -->
										<xsl:variable name="itemName">
											<xsl:call-template name="clean-up-identifier">
												<xsl:with-param name="text" select="$itemDef/@Name"/>
											</xsl:call-template>
										</xsl:variable>
										<!-- new code end -->
										<xsl:variable name="itemRepeatCnt" select="count($precedingRepeatingGroupDef/odm:ItemRef[@ItemOID = $ItemOIDval])"/>
										<xsl:variable name="isItemMultiSelect">
											<xsl:call-template name="is-item-multi-select">
												<xsl:with-param name="itemDef" select="$itemDef"/>
											</xsl:call-template>
										</xsl:variable>
										<!-- @pgawade 06/28/2010 To fix issue #0005275, commented out the condition to check the itemRepeatCnt value before calling "add-col-to-table" function because
												 it is no more needed after updating the function "add-col-to-table" to check if column to be added already exists in the table -->
										<!--<xsl:if test="$itemRepeatCnt = 0">										-->
										<!-- Item was not present in the earlier crf version. Add the column for this added item -->
										<xsl:choose>
											<xsl:when test="$itemDef/@DataType = 'partialDate'">
												<!-- For item with DataType="partialDate", create 2 columns of type date to store minimun and maximum date range values -->
												<xsl:variable name="partialDateMinValColName">
													<xsl:call-template name="partial-date-min-val-col-name">
														<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<xsl:with-param name="colName" select="$partialDateMinValColName"/>
													<xsl:with-param name="colDataType" select="'date'"/>
												</xsl:call-template>
												<xsl:variable name="partialDateMaxValColName">
													<xsl:call-template name="partial-date-max-val-col-name">
														<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<xsl:with-param name="colName" select="$partialDateMaxValColName"/>
													<xsl:with-param name="colDataType" select="'date'"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="$isItemMultiSelect='true'">
												<!-- For multi-select items create number of columns equal to number of items in the associated codelist -->
												<!-- 04/12/2010: Changes for "OpenClinica:MultiSelectListRef " child element in the definition of multi-select items -->
												<!--<xsl:variable name="codelistOID">
															<xsl:call-template name="get-codelist-OID">
																<xsl:with-param name="itemDef" select="$itemDef"/>	
															</xsl:call-template>
														</xsl:variable>-->
												<xsl:variable name="multiSelectListId">
													<xsl:call-template name="get-multi-select-list-id">
														<xsl:with-param name="itemDef" select="$itemDef"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:call-template name="get-multi-select-columns-alter-table-statements">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
													<!-- removed tbh 07/26/2010 -->
													<!--<xsl:with-param name="itemName" select="$itemName"/>-->
													<!--<xsl:with-param name="codelistOID" select="$codelistOID"/>-->
													<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<!-- column name as item OID and column data type as value of attribute DataType in the item definition -->
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<!--<xsl:with-param name="colName" select="@ItemOID"/>-->
													<xsl:with-param name="colName" select="$itemName"/>
													<xsl:with-param name="colDataType" select="$itemDef/@DataType"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
										<!-- Check if the item is single select, only if the item is not multi-select -->
										<xsl:if test="$isItemMultiSelect='false'">
											<xsl:variable name="isItemSingleSelect">
												<xsl:call-template name="is-item-single-select">
													<xsl:with-param name="itemDef" select="$itemDef"/>
												</xsl:call-template>
											</xsl:variable>
											<!-- Create additional column of type text to store the label for selected value from the corresponding code list -->
											<xsl:if test="$isItemSingleSelect='true'">
												<xsl:variable name="singleSelectLabelColName">
													<xsl:call-template name="get-col-name-single-select-label">
														<!--<xsl:with-param name="itemOID" select="$ItemOIDval"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:variable name="singleSelectLabelColDataType">
													<xsl:call-template name="get-col-data-type-single-select-label"/>
												</xsl:variable>
												<xsl:call-template name="add-col-to-table">
													<!-- @ccollins 5/12/10 added schema name to params -->
													<xsl:with-param name="schemaName" select="$studySchemaName"/>
													<xsl:with-param name="tableName" select="$tableName"/>
													<xsl:with-param name="colName" select="$singleSelectLabelColName"/>
													<xsl:with-param name="colDataType" select="$singleSelectLabelColDataType"/>
												</xsl:call-template>
											</xsl:if>
										</xsl:if>
										<!--</xsl:if>-->
									</xsl:for-each>
									<!-- *************** Table for repeated groupe items is already created; add the columns for newly added items in this CRF version end 
							********** -->
								</xsl:if>
								<!-- *********** INSERT DATA INTO for repeating group items TABLE start ***************  -->
								<!-- get Subject records for non repeating data -->
								<!-- THIS SHOULD BE REWRITTEN, will not scale to large datasets due to nested loops -->
								<!-- investigate using Muenchian Method - see  http://www.jenitennison.com/xslt/grouping/muenchian.html and 	
								http://ewbi.blogs.com/develops/2005/02/crosstabs_of_xm.html -->
								<!-- and/or preprocessing of the ODM - see http://www.xmldatabases.org/WK/blog/1086?t=item and 	
							http://www.movable-type.co.uk/scripts/itunes-albumlist.html -->
								<xsl:call-template name="insert-data-repeating-grp-items">
									<xsl:with-param name="formVersion" select="$formVersion"/>
									<xsl:with-param name="formVersionOID" select="$formVersionOID"/>
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
									<xsl:with-param name="itemGroupRefOID" select="$itemGroupRefOID"/>
									<xsl:with-param name="now" select="$now"/>
								</xsl:call-template>
								<!-- *********** INSERT DATA INTO for repeating items TABLE end ***************  -->
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="normalize-space($pFormNameFromVersion) != normalize-space($prevFormName)">
					<!-- version from new CRF  -->
					<!-- For non-grouped items -->
					<!-- Create the new table to store non-grouped items only once  -->
					<!-- Store the non-grouped item subject data into created non-grouped items table -->
					<xsl:for-each select="./odm:ItemGroupRef">
						<!-- *********** group start ***************  -->
						<xsl:variable name="itemGroupRefOID" select="@ItemGroupOID"/>
						<xsl:variable name="itemGroupDef" select="../../odm:ItemGroupDef[@OID=$itemGroupRefOID]"/>
						<xsl:variable name="groupName" select="$itemGroupDef/@Name"/>
						<xsl:choose>
							<xsl:when test="$itemGroupDef/@Repeating = 'No'">
								<!-- *********** Non-repeating group  ***************  -->
								<!-- ***** version from new CRF ///// Non-grouped item group ******* -->
								<!-- *********** CREATE TABLE for non-repeating items start ***************  -->
								<xsl:variable name="tableName">
									<xsl:call-template name="table-name-non-repeating-grp-items">
										<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="create-table-non-repeating-grp-items">
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
								</xsl:call-template>
								<xsl:call-template name="create-primary-key-non-repeating-grp-items">
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
								</xsl:call-template>
								<xsl:call-template name="create-foreign-key-non-repeating-grp-items">
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
									<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
								</xsl:call-template>
								<!-- @pgawade 07/21/2010 Added the foreign key constraint for crf_version referencing column crf_version_name from table crf_version	-->
								
								<!-- *********** CREATE TABLE or non-repeating items end ***************  -->
								<!-- *********** INSERT DATA INTO or non-repeating items TABLE start ***************  -->
								<!-- get Subject records for non repeating data -->
								<!-- THIS SHOULD BE REWRITTEN, will not scale to large datasets due to nested loops -->
								<!-- investigate using Muenchian Method - see  http://www.jenitennison.com/xslt/grouping/muenchian.html and 	
									http://ewbi.blogs.com/develops/2005/02/crosstabs_of_xm.html -->
								<!-- and/or preprocessing of the ODM - see http://www.xmldatabases.org/WK/blog/1086?t=item and 	
								http://www.movable-type.co.uk/scripts/itunes-albumlist.html -->
								<xsl:call-template name="insert-data-non-repeating-grp-items">
									<xsl:with-param name="formVersion" select="$formVersion"/>
									<xsl:with-param name="formVersionOID" select="$formVersionOID"/>
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
									<xsl:with-param name="itemGroupRefOID" select="$itemGroupRefOID"/>
									<xsl:with-param name="now" select="$now"/>
								</xsl:call-template>
								<!-- *********** INSERT DATA INTO or non-repeating items TABLE end ***************  -->
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$itemGroupDef/@Repeating = 'Yes'">
								<!-- **** version from new CRF ///// repeating item group******* -->
								<!-- For repeating group items -->
								<!-- Check if the table for the repeating group is already created; crete the sam if not -->
								<!-- Store the repeating group items subject data into created repeating groupe items data table -->
								<!-- table for repeating (aka grouped) items in the form -->
								<!-- *********** CREATE TABLE for repeating items start ***************  -->
								<!-- Table name is formed below with form_data_[group name]. Character '-' in the group name needs to replaced wit 
							some thing as it gives error when sql script is run. It is replaced with '_' here. -->
								<!-- Usegroup repeat key attribute value to differentiate the table names of repeating data groups. Beofre that confirm if 
								the separate table is reqd for repeating sets of data-->
								<!-- Table name = CRF name + repeating group name -->
								<xsl:variable name="tableName">
									<xsl:call-template name="table-name-repeating-grp-items">
										<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
										<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
										<xsl:with-param name="groupName" select="$groupName"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="create-table-repeating-grp-items">
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
								</xsl:call-template>
								<xsl:call-template name="create-primary-key-repeating-grp-items">
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
									<xsl:with-param name="groupName" select="$groupName"/>
								</xsl:call-template>
								<xsl:call-template name="create-foreign-key-repeating-grp-items">
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="study-schema-name" select="$studySchemaName"/>
									<xsl:with-param name="pFormNameFromVersion" select="$pFormNameFromVersion"/>
									<xsl:with-param name="groupName" select="$groupName"/>
								</xsl:call-template>
								<!-- @pgawade 07/21/2010 Added the foreign key constraint for crf_version referencing column crf_version_name from table crf_version	-->
									<xsl:variable name="tableNameWithoutSchema">
										<xsl:value-of select="$pFormNameFromVersion"/><xsl:value-of select="$groupName"/>
									</xsl:variable>
									
								<!-- *********** CREATE TABLE for repeating items end ***************  -->
								<!-- get Subject records for repeating data -->
								<!-- THIS SHOULD BE REWRITTEN, will not scale to large datasets due to nested loops -->
								<!-- investigate using Muenchian Method - see  http://www.jenitennison.com/xslt/grouping/muenchian.html and 
							http://ewbi.blogs.com/develops/2005/02/crosstabs_of_xm.html -->
								<!-- and/or preprocessing of the ODM - see http://www.xmldatabases.org/WK/blog/1086?t=item and 	
							http://www.movable-type.co.uk/scripts/itunes-albumlist.html -->
								<!--
							  <xsl:for-each select="/odm:ODM/odm:ClinicalData">
								 <xsl:for-each select="./odm:SubjectData">
								
								<xsl:variable name="subjectKey" select="@SubjectKey"/>
								
								<xsl:for-each select="./odm:StudyEventData">
								
								  <xsl:variable name="studyEventOID" select="@StudyEventOID"/>-->
								<!-- ORDINAL needs work, is buggy -->
								<!--
								  <xsl:variable name="studyEventOrdinal" select="count(preceding-sibling::*[name(current()) = name()]) + 1"/>
								  
								  <xsl:for-each select="./odm:FormData[@FormOID=$formOID]">
									
									<xsl:variable name="formDataOID" select="@FormOID"/>
									
									<xsl:for-each select="./odm:ItemGroupData[@ItemGroupOID=$itemGroupRefOID]">
									  <xsl:variable name="itemGroupData" select="."/>
									<tr>-->
								<!-- SSID -->
								<!--
								<td><xsl:value-of select="$subjectKey"/></td>
	
								<td><xsl:value-of select="$studyEventOID"/></td>-->
								<!-- Event Ordinal -->
								<!--
								<td><xsl:value-of select="$studyEventOrdinal"/></td>-->
								<!-- repeating CRF Items -->
								<!--
								<xsl:for-each select="$itemGroupDef/odm:ItemRef">
								  <xsl:variable name="itemRefOID" select="@ItemOID"/>
								  <td><xsl:value-of select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@Value"/></td>
								</xsl:for-each>
								</tr>
								</xsl:for-each>
							  </xsl:for-each>
	
							</xsl:for-each>
	
							  </xsl:for-each>	    		  
							</xsl:for-each>			
							</table>-->
								<!-- *********** INSERT DATA INTO for repeating group items TABLE start ***************  -->
								<!-- get Subject records for non repeating data -->
								<!-- THIS SHOULD BE REWRITTEN, will not scale to large datasets due to nested loops -->
								<!-- investigate using Muenchian Method - see  http://www.jenitennison.com/xslt/grouping/muenchian.html and 	
							http://ewbi.blogs.com/develops/2005/02/crosstabs_of_xm.html -->
								<!-- and/or preprocessing of the ODM - see http://www.xmldatabases.org/WK/blog/1086?t=item and 	
						http://www.movable-type.co.uk/scripts/itunes-albumlist.html -->
								<xsl:call-template name="insert-data-repeating-grp-items">
									<xsl:with-param name="formVersion" select="$formVersion"/>
									<xsl:with-param name="formVersionOID" select="$formVersionOID"/>
									<xsl:with-param name="tableName" select="$tableName"/>
									<xsl:with-param name="itemGroupDef" select="$itemGroupDef"/>
									<xsl:with-param name="itemGroupRefOID" select="$itemGroupRefOID"/>
									<!--<xsl:with-param name="crfName" select="$pFormNameFromVersion"/>-->
									<!--<xsl:with-param name="crf-status-summary-table-name" select="$crf-status-summary-table-name" />-->
									<!--<xsl:with-param name="study-schema-name" select="$studySchemaName"/>-->
									<xsl:with-param name="now" select="$now"/>
								</xsl:call-template>
								<!-- *********** INSERT DATA INTO for repeating items TABLE end ***************  -->
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!--************************************************************************************************************************************************************ -->
	</xsl:template>
	<!-- template to create schema name for a study -->
	<xsl:template name="schema-name-for-study">
		<!-- 04/12/2010 Changed the study schema name to have Protocol name instead of study OID, appended with data set name -->
		<!--<xsl:param name="studyOID"/>-->
		<xsl:param name="studyProtocolName"/>
		<xsl:param name="FileOID"/>
		<!-- @pgawade 06/24/2010 Commented out following separate template calls to cleap up individual special characters. Instead the schema name
				 will be passed to a template "clean-up-identifier" at the end -->
		<!--	old code start
			<xsl:variable name="studyProtocolNameWithoutSpaces">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="normalize-space($studyProtocolName)"/>
					<xsl:with-param name="replace" select="' '"/>
					<xsl:with-param name="by" select="'_'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="studyProtocolNameWithoutDash">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$studyProtocolNameWithoutSpaces"/>
					<xsl:with-param name="replace" select="'-'"/>
					<xsl:with-param name="by" select="'_'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="studyProtocolNameWithoutSpcChars">
				<xsl:call-template name="escape-special-sql-chars">
					<xsl:with-param name="dataValue" select="$studyProtocolNameWithoutDash"/>
				</xsl:call-template>
			</xsl:variable>
			old code end -->
		<xsl:variable name="FileOIDWithoutTimestamp">
			<xsl:call-template name="get-substring-before-last-occurance">
				<xsl:with-param name="text" select="$FileOID"/>
				<xsl:with-param name="token" select="'D20'"/>
			</xsl:call-template>
		</xsl:variable>
		<!--<xsl:value-of select="$studyOID"/><xsl:text>_</xsl:text><xsl:value-of select="$FileOIDWithoutTimestamp"/>-->
		<!-- old code: <xsl:value-of select="$studyProtocolNameWithoutSpcChars"/><xsl:text>_</xsl:text><xsl:value-of select="$FileOIDWithoutTimestamp"/>-->
		<!-- new code start -->
		<xsl:variable name="studySchemaName">
			<xsl:value-of select="$studyProtocolName"/>
			<xsl:text>_</xsl:text>
			<xsl:value-of select="$FileOIDWithoutTimestamp"/>
		</xsl:variable>
		<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$studySchemaName"/>
		</xsl:call-template>
		<!-- new code end -->
	</xsl:template>
	<!-- template to drop the schema for study -->
	<xsl:template name="drop-schema-for-study">
		<xsl:param name="schema-name"/>
			DROP SCHEMA IF EXISTS <xsl:value-of select="$schema-name"/> CASCADE;
		</xsl:template>
	<!-- template to create the schema for a study -->
	<xsl:template name="create-schema_for_study">
		<xsl:param name="schema-name"/>
			CREATE SCHEMA <xsl:value-of select="$schema-name"/>;
			
			create or replace function <xsl:value-of select="$schema-name"/>.add_table_field (p_table text, p_field text, p_datatype text) 
			returns bool as '
			DECLARE

			  v_row       record;
			  v_query     text;
			BEGIN
			  SELECT 1 into v_row FROM information_schema.columns where table_catalog = current_database() and table_schema= lower(substring(p_table from ''^[^\.]*'')) and table_name= lower(substring(p_table from ''[^\.]*$'')) and column_name = lower(p_field);
			  if found then
			    raise notice '' column already exists, skipping '';
			    return ''t'';
			  else
			    raise notice '' column not present, adding to table '';
			    v_query := ''alter table '' || p_table || '' add column '' || p_field || '' '' || p_datatype || '';'';
			    execute v_query;
			    return ''f'';
			  end if;
			END;' language plpgsql;


		</xsl:template>
	<!-- template to form the table name for non-repeating group items -->
	<xsl:template name="table-name-non-repeating-grp-items">
		<xsl:param name="study-schema-name"/>
		<xsl:param name="pFormNameFromVersion"/>
		<!-- @pgawade 06/24/2010 Changed the template call to "" to check all for valid SQL identifiers together -->
		<!--old code:<xsl:variable name="pFormNameFromVersionRemovedStartNumbers">				
				 <xsl:call-template name="remove-starting-numbers-from-string">				
					<xsl:with-param name="text" select="$pFormNameFromVersion"/>
				</xsl:call-template>
			</xsl:variable>				-->
		<!-- table name = [schema name].[parent form name] -->
		<!-- old code:
			<xsl:variable name="tableName">
				 <xsl:value-of select="$study-schema-name"></xsl:value-of>.<xsl:value-of select="$pFormNameFromVersionRemovedStartNumbers"></xsl:value-of>-->
		<xsl:variable name="pFormNameFromVersionCleaned">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$pFormNameFromVersion"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$study-schema-name"/>.<xsl:value-of select="$pFormNameFromVersionCleaned"/>
		<!--old code:
			</xsl:variable>			
			<xsl:call-template name="escape-special-sql-chars-table-name">
				<xsl:with-param name="tableName" select="$tableName"/>
			</xsl:call-template>	-->
	</xsl:template>
	<!-- template to create the table for non-repeating group items -->
	<xsl:template name="create-table-non-repeating-grp-items">
		<xsl:param name="tableName"/>
		<xsl:param name="itemGroupDef"/>
			create table <xsl:value-of select="normalize-space($tableName)"/> (
			<!-- Following sql comments output is commented out because could not output the sql scr ipt after this on new line-->
		<!-- <xsl:text> following columns are static</xsl:text>-->
			item_data_id serial NOT NULL,
			ssoid character varying(40) NOT NULL,
			ssid character varying(40) NOT NULL,
			study_event_oid character varying(40) NOT NULL,
			event_ordinal integer default 1,
			crf_version character varying(255),
			event_start_date timestamp without time zone,
			event_end_date timestamp without time zone,
			event_status character varying(255),
			event_location character varying(2000),
			subject_age_at_event integer,
			crf_status character varying(255), 
			interviewerName character varying(255),
			interviewDate date,
			warehouse_insert_created_timestamp timestamp with time zone, 			          	 
			<xsl:for-each select="$itemGroupDef/odm:ItemRef">
			<xsl:variable name="ItemOIDval" select="@ItemOID"/>
			<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$ItemOIDval]"/>
			<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up invalid characters in the item name identifiers to avoid the SQL exception -->
			<!-- old code:
				<xsl:variable name="itemNamePre">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$itemDef/@Name"/>
						<xsl:with-param name="replace" select="' '"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="itemName">
					<xsl:call-template name="escape-special-sql-chars">
						<xsl:with-param name="dataValue"	select="$itemNamePre"/>
					</xsl:call-template>
				</xsl:variable>-->
			<!-- new code start -->
			<xsl:variable name="itemName">
				<xsl:call-template name="clean-up-identifier">
					<xsl:with-param name="text" select="$itemDef/@Name"/>
				</xsl:call-template>
			</xsl:variable>
			<!-- new code end -->
			<xsl:variable name="isItemMultiSelect">
				<xsl:call-template name="is-item-multi-select">
					<xsl:with-param name="itemDef" select="$itemDef"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$itemDef/@DataType = 'partialDate'">
					<!-- For item with DataType="partialDate", create 2 columns of type date to store minimun and maximum date range values -->
					<xsl:call-template name="partial-date-min-val-col-name">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text> date,
						<xsl:call-template name="partial-date-max-val-col-name">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text> date	
					</xsl:when>
				<xsl:when test="$isItemMultiSelect='true'">
					<!-- For multi-select items create number of columns equal to number of items in the associated codelist -->
					<!-- 04/12/2010: Changes for "OpenClinica:MultiSelectListRef " child element in the definition of multi-select items -->
					<xsl:variable name="multiSelectListId">
						<xsl:call-template name="get-multi-select-list-id">
							<xsl:with-param name="itemDef" select="$itemDef"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="get-multi-select-column-names-with-data-type">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="$ItemOIDval"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
						<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- column name as item OID and column data type as value of attribute DataType in the item definition -->
					<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
					<!-- <xsl:value-of select="@ItemOID"/><xsl:text> </xsl:text> <xsl:value-of select="$itemDef/@DataType"/>	-->
					<xsl:value-of select="$itemName"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$itemDef/@DataType"/>
				</xsl:otherwise>
			</xsl:choose>
			<!-- Check if the item is single select only if item is not multi-select-->
			<xsl:if test="$isItemMultiSelect='false'">
				<xsl:variable name="isItemSingleSelect">
					<xsl:call-template name="is-item-single-select">
						<xsl:with-param name="itemDef" select="$itemDef"/>
					</xsl:call-template>
				</xsl:variable>
				<!-- Create additional column of type text to store the label for selected value from the corresponding code list -->
				<xsl:if test="$isItemSingleSelect='true'">
						,<xsl:call-template name="get-col-name-single-select-label">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:call-template name="get-col-data-type-single-select-label"/>
				</xsl:if>
			</xsl:if>
			<xsl:if test="not(position()=last())">, </xsl:if>
		</xsl:for-each>
			);	
		</xsl:template>
	<!-- template to create primary key constraint sql statement for non-repeating group items table -->
	<xsl:template name="create-primary-key-non-repeating-grp-items">
		<xsl:param name="tableName"/>
		<xsl:param name="pFormNameFromVersion"/>
		<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
		<!-- old code
			<xsl:variable name="tableNameWithoutSchema50Chars" select="substring($pFormNameFromVersion, 1,  50)"/>
			<xsl:variable name="tableNameWithoutSchema50CharsEscaped">
				<xsl:call-template name="escape-special-sql-chars-table-name">
					<xsl:with-param name="tableName" select="$tableNameWithoutSchema50Chars"/>
				</xsl:call-template>
			</xsl:variable> 
			-->
		<!--<xsl:variable name="dot-removed-tableName">
				<xsl:call-template name="string-replace-all">
				   <xsl:with-param name="text" select="normalize-space($tableName)" />
				   <xsl:with-param name="replace" select="'.'" />
				   <xsl:with-param name="by" select="'_'" />
				</xsl:call-template>
			</xsl:variable>-->
		<!-- old code ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Pk_<xsl:value-of select="
								normalize-space($tableNameWithoutSchema50CharsEscaped)"/>PRIMARY KEY (item_data_id);-->
		<!-- new code start -->
		<xsl:variable name="constraint-name">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$pFormNameFromVersion"/>
			</xsl:call-template>
		</xsl:variable>
				
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Pk_<xsl:value-of select="normalize-space($constraint-name)"/> PRIMARY KEY (item_data_id);
			 <!-- new code end -->
	</xsl:template>
	<!-- template to create foreign key constraint sql statement for non-repeating group items table -->
	<xsl:template name="create-foreign-key-non-repeating-grp-items">
		<xsl:param name="tableName"/>
		<xsl:param name="study-schema-name"/>
		<xsl:param name="pFormNameFromVersion"/>
		<!--<xsl:variable name="dot-removed-tableName">
				<xsl:call-template name="string-replace-all">
				   <xsl:with-param name="text" select="normalize-space($tableName)" />
				   <xsl:with-param name="replace" select="'.'" />
				   <xsl:with-param name="by" select="'_'" />
				</xsl:call-template>
			</xsl:variable>-->
		<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
		<!-- old code 	
			<xsl:variable name="tableNameWithoutSchema50Chars" select="substring($pFormNameFromVersion, 1,  50)"/>
			<xsl:variable name="tableNameWithoutSchema50CharsEscaped">
				<xsl:call-template name="escape-special-sql-chars-table-name">
					<xsl:with-param name="tableName" select="$tableNameWithoutSchema50Chars"/>
				</xsl:call-template>
			</xsl:variable>
			
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Fk_study_subject_id_<xsl:value-of select="normalize-space($tableNameWithoutSchema50CharsEscaped)"/> FOREIGN KEY (ssoid, ssid) REFERENCES <xsl:value-of select="$study-schema-name"/>.study_subject_listing;-->
		<!-- new code start -->
		<xsl:variable name="constraint-name">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$pFormNameFromVersion"/>
			</xsl:call-template>
		</xsl:variable>		
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Fk_study_subject_id_<xsl:value-of select="normalize-space($constraint-name)"/> FOREIGN KEY (ssoid, ssid) REFERENCES <xsl:value-of select="$study-schema-name"/>.study_subject_listing;
			<!-- new code end -->
	</xsl:template>
	<!-- template to insert data into non-repeating group items -->
	<xsl:template name="insert-data-non-repeating-grp-items">
		<xsl:param name="formVersion"/>
		<xsl:param name="formVersionOID"/>
		<xsl:param name="tableName"/>
		<xsl:param name="itemGroupRefOID"/>
		<xsl:param name="itemGroupDef"/>
		<xsl:param name="now"/>
		<xsl:for-each select="/odm:ODM/odm:ClinicalData">
			<xsl:for-each select="./odm:SubjectData">
				<xsl:variable name="ssoid" select="@SubjectKey"/>
				<xsl:variable name="ssid" select="@OpenClinica:StudySubjectId"/>
				<xsl:for-each select="./odm:StudyEventData">
					<xsl:variable name="studyEventOID" select="@StudyEventOID"/>
					<xsl:variable name="eventStartDate" select="@OpenClinica:StartDate"/>
					<xsl:variable name="eventEndDate" select="@OpenClinica:EndDate"/>
					<xsl:variable name="eventLocation" select="@OpenClinica:StudyEventLocation"/>
					<xsl:variable name="subjectAgeAtEvent" select="@OpenClinica:SubjectAgeAtEvent"/>
					<xsl:variable name="eventStatus" select="@OpenClinica:Status"/>
					<!-- Value for study event ordinal -->
					<xsl:variable name="studyEventOrdinal" select="@StudyEventRepeatKey"/>
					<xsl:for-each select="./odm:FormData[@FormOID=$formVersionOID]">
						<xsl:variable name="formDataOID" select="@FormOID"/>
						<xsl:variable name="crfStatus" select="@OpenClinica:Status"/>
						<xsl:variable name="interviewerName" select="@OpenClinica:InterviewerName"/>
						<xsl:variable name="interviewDate" select="@OpenClinica:InterviewDate"/>
						<xsl:variable name="itemGroupData" select="./odm:ItemGroupData[@ItemGroupOID=$itemGroupRefOID]"/>
						<xsl:if test="$itemGroupData">
								insert into <xsl:value-of select="$tableName"/> (
								ssoid, ssid, study_event_oid
								<xsl:if test="$studyEventOrdinal"> 
									,event_ordinal
								</xsl:if>	
								,crf_version
								<xsl:if test="$eventStartDate">, event_start_date</xsl:if>
							<xsl:if test="$eventEndDate">, event_end_date</xsl:if>
							<xsl:if test="$eventStatus">, event_status</xsl:if>
							<xsl:if test="$eventLocation">, event_location</xsl:if>
							<xsl:if test="$subjectAgeAtEvent">, subject_age_at_event</xsl:if>
							<xsl:if test="$crfStatus">, crf_status</xsl:if>
							<xsl:if test="$interviewerName">, interviewerName</xsl:if>
							<xsl:if test="$interviewDate">, interviewDate</xsl:if>
								, warehouse_insert_created_timestamp
								<xsl:for-each select="$itemGroupDef/odm:ItemRef">
								<xsl:variable name="itemRefOID" select="@ItemOID"/>
								<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$itemRefOID]"/>
								<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
								<!-- old code
									<xsl:variable name="itemNamePre">
										<xsl:call-template name="string-replace-all">
											<xsl:with-param name="text" select="$itemDef/@Name"/>
											<xsl:with-param name="replace" select="' '"/>
											<xsl:with-param name="by" select="'_'"/>
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="itemName">
										<xsl:call-template name="escape-special-sql-chars">
											<xsl:with-param name="dataValue"	select="$itemNamePre"/>
										</xsl:call-template>
									</xsl:variable>
									-->
								<!-- new code start -->
								<xsl:variable name="itemName">
									<xsl:call-template name="clean-up-identifier">
										<xsl:with-param name="text" select="$itemDef/@Name"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- new code end -->
								<xsl:variable name="isItemMultiSelect">
									<xsl:call-template name="is-item-multi-select">
										<xsl:with-param name="itemDef" select="$itemDef"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:if test="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]">
									<xsl:choose>
										<xsl:when test="$itemDef/@DataType = ('partialDate')">													
													,<xsl:call-template name="partial-date-min-val-col-name">
												<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
												<!--<xsl:with-param name="itemOID" select="$itemRefOID"/>-->
												<xsl:with-param name="itemName" select="$itemName"/>
											</xsl:call-template>													
													,<xsl:call-template name="partial-date-max-val-col-name">
												<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
												<!--<xsl:with-param name="itemOID" select="$itemRefOID"/>-->
												<xsl:with-param name="itemName" select="$itemName"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="$isItemMultiSelect='true'">
											<!-- For multi-select items insert the true/false into multiple columns created depending on values entered by user -->
											<xsl:variable name="itemValue" select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@Value"/>
											<!-- value of attribute 'IsNull' in the 'ItemData' element -->
											<xsl:variable name="isNullValue" select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@IsNull"/>
											<!-- 04/12/2010: Changes for "OpenClinica:MultiSelectListRef " child element in the definition of multi-select items -->
											<!--<xsl:variable name="codelistOID">
														<xsl:call-template name="get-codelist-OID">
															<xsl:with-param name="itemDef" select="$itemDef"/>	
														</xsl:call-template>
													</xsl:variable>-->
											<xsl:variable name="multiSelectListId">
												<xsl:call-template name="get-multi-select-list-id">
													<xsl:with-param name="itemDef" select="$itemDef"/>
												</xsl:call-template>
											</xsl:variable>
											<!-- generate the column names corresponding to multi-select value options selected by user -->
											<xsl:choose>
												<xsl:when test="$isNullValue = 'Yes'">
													<xsl:call-template name="get-multi-select-all-column-names">
														<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
														<!--<xsl:with-param name="itemOID" select="$itemRefOID"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
														<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="get-multi-select-column-names-for-values-selected">
														<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
														<!--<xsl:with-param name="itemOID" select="$itemRefOID"/>-->
														<xsl:with-param name="itemName" select="$itemName"/>
														<xsl:with-param name="itemValue" select="$itemValue"/>
														<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>																									
													,
													<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
											<!--<xsl:value-of select="@ItemOID"/>-->
											<xsl:value-of select="$itemName"/>
										</xsl:otherwise>
									</xsl:choose>
									<!-- Check if the item is single select, only if the item is not multi-select -->
									<xsl:if test="$isItemMultiSelect='false'">
										<xsl:variable name="isItemSingleSelect">
											<xsl:call-template name="is-item-single-select">
												<xsl:with-param name="itemDef" select="$itemDef"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:if test="$isItemSingleSelect='true'">
											<!-- single-select items -->														
														,<xsl:call-template name="get-col-name-single-select-label">
												<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
												<!--<xsl:with-param name="itemOID" select="@ItemOID">-->
												<xsl:with-param name="itemName" select="$itemName">	
														</xsl:with-param>
											</xsl:call-template>
										</xsl:if>
									</xsl:if>
								</xsl:if>
							</xsl:for-each>
								)
								values (
								<!-- data for columns Event Start Date,  Event Status, Event Status, CRF Status is hardcoded here 
								temporarily -->
							<!-- SSOID -->
								'<xsl:value-of select="$ssoid"/>',
								<!-- SSID -->
								'<xsl:value-of select="$ssid"/>', 	 									
								<!-- Study Event OID -->
								'<xsl:value-of select="$studyEventOID"/>' 									  
								<!-- Event Ordinal -->
							<xsl:if test="$studyEventOrdinal">
									,<xsl:value-of select="$studyEventOrdinal"/>
							</xsl:if>
							<!-- CRF version  --> 
								,'<xsl:value-of select="$formVersion"/>'																				  
								<!-- Event Start Date -->
							<xsl:if test="$eventStartDate">,'<xsl:value-of select="$eventStartDate"/>' </xsl:if>
							<!-- Event End Date -->
							<xsl:if test="$eventEndDate">,'<xsl:value-of select="$eventEndDate"/>' </xsl:if>
							<!-- Event Status -->
							<xsl:if test="$eventStatus">,'<xsl:value-of select="$eventStatus"/>' </xsl:if>
							<!-- Event Location -->
							<xsl:if test="$eventLocation">,'<xsl:value-of select="$eventLocation"/>' </xsl:if>
							<!-- Subject age at an event -->
							<xsl:if test="$subjectAgeAtEvent">,'<xsl:value-of select="$subjectAgeAtEvent"/>' </xsl:if>
							<!-- CRF Status -->
							<xsl:if test="$crfStatus">,'<xsl:value-of select="$crfStatus"/>'</xsl:if>
							<!-- Interviewer name -->
							<xsl:if test="$interviewerName">,'<xsl:value-of select="$interviewerName"/>'</xsl:if>
							<!-- Interview date -->
							<xsl:if test="$interviewDate">,'<xsl:value-of select="$interviewDate"/>'</xsl:if>
							<!-- last updated timestamp -->
								, '<xsl:value-of select="$now"/>'
								<!-- non-repeating CRF Items -->
							<xsl:for-each select="$itemGroupDef/odm:ItemRef">
								<xsl:variable name="itemRefOID" select="@ItemOID"/>
								<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$itemRefOID]"/>
								<xsl:variable name="isItemMultiSelect">
									<xsl:call-template name="is-item-multi-select">
										<xsl:with-param name="itemDef" select="$itemDef"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="isItemSingleSelect">
									<xsl:call-template name="is-item-single-select">
										<xsl:with-param name="itemDef" select="$itemDef"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:if test="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]">
									<xsl:variable name="itemValue" select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@Value"/>
									<!-- value of attribute 'IsNull' in the 'ItemData' element -->
									<xsl:variable name="isNullValue" select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@IsNull"/>
									<xsl:choose>
										<xsl:when test="$isNullValue = 'Yes'">
											<!-- Insert SQL NULL value in case value of attribute 'IsNull' in the 'ItemData' element is 'Yes' -->
											<xsl:choose>
												<xsl:when test="$itemDef/@DataType = ('partialDate')">
													<!-- insert null value for both the columns for partial date -->
														,null, null
													</xsl:when>
												<xsl:when test="$isItemMultiSelect='true'">
													<!-- insert null values for all the columns of multi-select item -->
													<!--<xsl:variable name="codelistOID">
															<xsl:call-template name="get-codelist-OID">
																<xsl:with-param name="itemDef" select="$itemDef"/>	
															</xsl:call-template>
														</xsl:variable>-->
													<xsl:variable name="multiSelectListId">
														<xsl:call-template name="get-multi-select-list-id">
															<xsl:with-param name="itemDef" select="$itemDef"/>
														</xsl:call-template>
													</xsl:variable>
													<xsl:call-template name="get-multi-select-all-null-column-values">
														<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
														,null
													</xsl:otherwise>
											</xsl:choose>
											<xsl:if test="$isItemSingleSelect='true'">
												<!-- insert null values into single-select item label column -->
													,null											
												</xsl:if>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="$isItemMultiSelect='true'">
													<xsl:call-template name="get-multi-select-column-values">
														<xsl:with-param name="itemValue" select="$itemValue"/>
													</xsl:call-template>
												</xsl:when>
												<xsl:otherwise>
														,<xsl:if test="$itemDef/@DataType = 'date'">'</xsl:if>
													<!-- @ccollins 6/03/10 removed E character for text datatypes -->
													<xsl:if test="$itemDef/@DataType = ('text')">'</xsl:if>
													<xsl:choose>
														<xsl:when test="$itemDef/@DataType = ('text')">
															<xsl:call-template name="escape-special-sql-chars">
																<xsl:with-param name="dataValue" select="$itemValue"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:when test="$itemDef/@DataType = ('partialDate')">
															<!-- get the min and maximum date values to be inserted for partial date item -->
															<xsl:call-template name="partial-date-min-date-val">
																<xsl:with-param name="itemValue" select="$itemValue"/>
															</xsl:call-template>,												
																<xsl:call-template name="partial-date-max-date-val">
																<xsl:with-param name="itemValue" select="$itemValue"/>
															</xsl:call-template>
														</xsl:when>
														<!-- @ccollins 6/03/10 added test for int, real, date datatypes to handle null (temporary fix) -->
														<xsl:when test="$itemDef/@DataType = ('integer') or $itemDef/@DataType = ('real') or $itemDef/@DataType = ('date')">
															<xsl:choose>
																<xsl:when test="string(number($itemValue)) = 'NaN' and $itemDef/@DataType != ('date')">
																		NULL
																	</xsl:when>
																<xsl:when test="$itemValue = ''">
																		NULL
																	</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="$itemValue"/>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="$itemValue"/>
														</xsl:otherwise>
													</xsl:choose>
													<xsl:if test="$itemDef/@DataType = 'date'">'</xsl:if>
													<xsl:if test="$itemDef/@DataType = ('text')">'</xsl:if>
												</xsl:otherwise>
											</xsl:choose>
											<!-- Insert value into label column for single select items -->
											<!-- Check if the item is single select, only if item is not multi-select -->
											<xsl:if test="$isItemMultiSelect='false'">
												<xsl:if test="$isItemSingleSelect='true'">
													<!-- single-select items -->
													<xsl:variable name="codeListOID">
														<xsl:call-template name="get-codelist-OID">
															<xsl:with-param name="itemDef" select="$itemDef"/>
														</xsl:call-template>
													</xsl:variable>													
														,'<xsl:call-template name="get-label-from-codelist">
														<xsl:with-param name="codelistOID" select="$codeListOID"/>
														<xsl:with-param name="itemValue" select="$itemValue"/>
													</xsl:call-template>'											
													</xsl:if>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:for-each>		
								);
							</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	<!-- template name to form the table name for repeating group items -->
	<xsl:template name="table-name-repeating-grp-items">
		<xsl:param name="study-schema-name"/>
		<xsl:param name="pFormNameFromVersion"/>
		<xsl:param name="groupName"/>
		<xsl:variable name="tableNamePreComp">
			<xsl:value-of select="$pFormNameFromVersion"/>
			<xsl:value-of select="$groupName"/>
		</xsl:variable>
		<!-- @pgawade 06/24/2010 Changed the template call to "" to check all for valid SQL identifiers together -->
		<!-- old code: <xsl:variable name="tableNamePreCompRemovedStartNumbers">			
				<xsl:call-template name="remove-starting-numbers-from-string">
					<xsl:with-param name="text" select="$tableNamePreComp"/>
				</xsl:call-template>
			</xsl:variable>-->
		<!-- table name = [schema name].[parent form name] -->
		<!-- old code
			<xsl:variable name="tableName">
				 <xsl:value-of select="$study-schema-name"></xsl:value-of>.<xsl:value-of select="$tableNamePreCompRemovedStartNumbers"></xsl:value-of>-->
		<xsl:variable name="tableNamePreCompCleaned">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="normalize-space($tableNamePreComp)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$study-schema-name"/>.<xsl:value-of select="$tableNamePreCompCleaned"/>
		<!-- old code:
			</xsl:variable>			
			 <xsl:call-template name="escape-special-sql-chars-table-name">
				<xsl:with-param name="tableName" select="$tableName"/>
			</xsl:call-template>-->
	</xsl:template>
	<!-- template to create the table for repeating group items -->
	<xsl:template name="create-table-repeating-grp-items">
		<xsl:param name="tableName"/>
		<xsl:param name="itemGroupDef"/>
			create table <xsl:value-of select="normalize-space($tableName)"/> (		
			item_data_id serial NOT NULL,	
			ssoid character varying(40) NOT NULL,			
			ssid character varying(40) NOT NULL,
			study_event_oid character varying(40) NOT NULL,
			event_ordinal integer default 1,	
			crf_version character varying(255),
			event_start_date timestamp without time zone,
			event_end_date timestamp without time zone,
			event_status character varying(255),
			event_location character varying(2000),
			subject_age_at_event integer,
			crf_status character varying(255), 
			interviewerName character varying(255),
			interviewDate date, 
			item_group_repeat_key integer,
			warehouse_insert_created_timestamp timestamp with time zone,						             	 
			<xsl:for-each select="$itemGroupDef/odm:ItemRef">
			<xsl:variable name="ItemOIDval" select="@ItemOID"/>
			<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$ItemOIDval]"/>
			<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up invalid characters in the item name identifiers to avoid the SQL exception -->
			<!-- old code: 
				<xsl:variable name="itemNamePre">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$itemDef/@Name"/>
						<xsl:with-param name="replace" select="' '"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="itemName">
					<xsl:call-template name="escape-special-sql-chars">
						<xsl:with-param name="dataValue"	select="$itemNamePre"/>
					</xsl:call-template>
				</xsl:variable>	
				-->
			<!-- new code start -->
			<xsl:variable name="itemName">
				<xsl:call-template name="clean-up-identifier">
					<xsl:with-param name="text" select="$itemDef/@Name"/>
				</xsl:call-template>
			</xsl:variable>
			<!-- new code end -->
			<xsl:variable name="isItemMultiSelect">
				<xsl:call-template name="is-item-multi-select">
					<xsl:with-param name="itemDef" select="$itemDef"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$itemDef/@DataType = 'partialDate'">
					<!-- For item with DataType="partialDate", create 2 columns of type date to store minimun and maximum date range values -->
					<xsl:call-template name="partial-date-min-val-col-name">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text> date,						
						<xsl:call-template name="partial-date-max-val-col-name">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text> date					
					</xsl:when>
				<xsl:when test="$isItemMultiSelect='true'">
					<!-- For multi-select items create number of columns equal to number of items in the associated codelist -->
					<!--<xsl:variable name="codelistOID">
							<xsl:call-template name="get-codelist-OID">
								<xsl:with-param name="itemDef" select="$itemDef"/>	
							</xsl:call-template>
						</xsl:variable>-->
					<xsl:variable name="multiSelectListId">
						<xsl:call-template name="get-multi-select-list-id">
							<xsl:with-param name="itemDef" select="$itemDef"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="get-multi-select-column-names-with-data-type">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="$ItemOIDval"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
						<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- column name as item OID and column data type as value of attribute DataType in the item definition -->
					<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
					<!--<xsl:value-of select="@ItemOID"/>-->
					<xsl:value-of select="$itemName"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$itemDef/@DataType"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="$isItemMultiSelect='false'">
				<!-- Check if the item is single select only if item is not multi-select-->
				<xsl:variable name="isItemSingleSelect">
					<xsl:call-template name="is-item-single-select">
						<xsl:with-param name="itemDef" select="$itemDef"/>
					</xsl:call-template>
				</xsl:variable>
				<!-- Create additional column of type text to store the label for selected value from the corresponding code list -->
				<xsl:if test="$isItemSingleSelect='true'">
						,<xsl:call-template name="get-col-name-single-select-label">
						<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
						<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
						<xsl:with-param name="itemName" select="$itemName"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:call-template name="get-col-data-type-single-select-label"/>
				</xsl:if>
			</xsl:if>
			<xsl:if test="not(position()=last())">, </xsl:if>
		</xsl:for-each>
			);
		</xsl:template>
	<!-- template to add column to a table -->
	<xsl:template name="add-col-to-table">
		<!-- @ccollins 5/11/10 added schema param to support add column function -->
		<xsl:param name="schemaName"/>
		<xsl:param name="tableName"/>
		<xsl:param name="colName"/>
		<xsl:param name="colDataType"/>
		<!-- @ccollins 5/11/10 added special add column function that checks for existing column of same name before adding; as a (temporary?) fix to duplicates bug -->
			SELECT <xsl:value-of select="$schemaName"/>.add_table_field('<xsl:value-of select="normalize-space($tableName)"/>', '<xsl:value-of select="$colName"/>', '<xsl:value-of select="$colDataType"/>');
<!-- old code:
			Alter table <xsl:value-of select="normalize-space($tableName)"/> add column								  
			<xsl:value-of select="$colName"/><xsl:text> </xsl:text> <xsl:value-of select="$colDataType"/>;
-->
	</xsl:template>
	<!-- template to create primary key constraint sql statement for repeating group items table -->
	<xsl:template name="create-primary-key-repeating-grp-items">
		<xsl:param name="tableName"/>
		<xsl:param name="pFormNameFromVersion"/>
		<xsl:param name="groupName"/>
		<!--<xsl:variable name="dot-removed-tableName">
				<xsl:call-template name="string-replace-all">
				   <xsl:with-param name="text" select="normalize-space($tableName)" />
				   <xsl:with-param name="replace" select="'.'" />
				   <xsl:with-param name="by" select="'_'" />
				</xsl:call-template>
			</xsl:variable>-->
		<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
		<!-- old code	
			<xsl:variable name="pFormNameFromVersion50Chars" select="substring($pFormNameFromVersion, 1,  50)"/>
			<xsl:variable name="tableNameWithoutSchema50Chars">
				<xsl:value-of select="$pFormNameFromVersion50Chars"/><xsl:value-of select="$groupName"/>
			</xsl:variable>
			<xsl:variable name="tableNameWithoutSchema50CharsEscaped">
				<xsl:call-template name="escape-special-sql-chars-table-name">
					<xsl:with-param name="tableName" select="$tableNameWithoutSchema50Chars"/>
				</xsl:call-template>
			</xsl:variable>
			
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Pk_<xsl:value-of select="
								normalize-space($tableNameWithoutSchema50CharsEscaped)"/> PRIMARY KEY (item_data_id);
			-->
		<!-- new code start -->
		<xsl:variable name="constraint-name-text">
			<xsl:value-of select="$pFormNameFromVersion"/>
			<xsl:value-of select="$groupName"/>
		</xsl:variable>
		<xsl:variable name="constraint-name">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$constraint-name-text"/>
			</xsl:call-template>
		</xsl:variable>
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Pk_<xsl:value-of select="
								normalize-space($constraint-name)"/> PRIMARY KEY (item_data_id);
			<!-- new code end -->
	</xsl:template>
	<!-- template to create foreign key constraint sql statement for repeating group items table -->
	<xsl:template name="create-foreign-key-repeating-grp-items">
		<xsl:param name="tableName"/>
		<xsl:param name="study-schema-name"/>
		<xsl:param name="pFormNameFromVersion"/>
		<xsl:param name="groupName"/>
		<!--<xsl:variable name="dot-removed-tableName">
				<xsl:call-template name="string-replace-all">
				   <xsl:with-param name="text" select="normalize-space($tableName)" />
				   <xsl:with-param name="replace" select="'.'" />
				   <xsl:with-param name="by" select="'_'" />
				</xsl:call-template>
			</xsl:variable>-->
		<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
		<!-- old code
			<xsl:variable name="pFormNameFromVersion50Chars" select="substring($pFormNameFromVersion, 1,  50)"/>
			<xsl:variable name="tableNameWithoutSchema50Chars">
				<xsl:value-of select="$pFormNameFromVersion50Chars"/><xsl:value-of select="$groupName"/>
			</xsl:variable>
			<xsl:variable name="tableNameWithoutSchema50CharsEscaped">
				<xsl:call-template name="escape-special-sql-chars-table-name">
					<xsl:with-param name="tableName" select="$tableNameWithoutSchema50Chars"/>
				</xsl:call-template>
			</xsl:variable>		
			
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Fk_study_subject_id_<xsl:value-of select="
								normalize-space($tableNameWithoutSchema50CharsEscaped)"/> FOREIGN KEY (ssoid, ssid) REFERENCES <xsl:value-of select="$study-schema-name"/>.study_subject_listing;
            -->
		<!-- new code start -->
		<xsl:variable name="constraint-name-text">
			<xsl:value-of select="$pFormNameFromVersion"/>
			<xsl:value-of select="$groupName"/>
		</xsl:variable>
		<xsl:variable name="constraint-name">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$constraint-name-text"/>
			</xsl:call-template>
		</xsl:variable>
			ALTER TABLE <xsl:value-of select="normalize-space($tableName)"/> ADD CONSTRAINT Fk_study_subject_id_<xsl:value-of select="
								normalize-space($constraint-name)"/> FOREIGN KEY (ssoid, ssid) REFERENCES <xsl:value-of select="$study-schema-name"/>.study_subject_listing;
            <!-- new code end -->
	</xsl:template>
	<!-- template to insert data into repeating group items -->
	<xsl:template name="insert-data-repeating-grp-items">
		<xsl:param name="formVersion"/>
		<xsl:param name="formVersionOID"/>
		<xsl:param name="tableName"/>
		<xsl:param name="itemGroupRefOID"/>
		<xsl:param name="itemGroupDef"/>
		<xsl:param name="now"/>
		<xsl:for-each select="/odm:ODM/odm:ClinicalData">
			<xsl:for-each select="./odm:SubjectData">
				<xsl:variable name="ssoid" select="@SubjectKey"/>
				<xsl:variable name="ssid" select="@OpenClinica:StudySubjectId"/>
				<!-- <xsl:key name="SEDKey" match="StudyEventData" use="@StudyEventOID" /> -->
				<xsl:for-each select="./odm:StudyEventData">
					<xsl:variable name="studyEventOID" select="@StudyEventOID"/>
					<xsl:variable name="eventStartDate" select="@OpenClinica:StartDate"/>
					<xsl:variable name="eventEndDate" select="@OpenClinica:EndDate"/>
					<xsl:variable name="eventLocation" select="@OpenClinica:StudyEventLocation"/>
					<xsl:variable name="subjectAgeAtEvent" select="@OpenClinica:SubjectAgeAtEvent"/>
					<xsl:variable name="eventStatus" select="@OpenClinica:Status"/>
					<!-- Value for study event ordinal -->
					<xsl:variable name="studyEventOrdinal" select="@StudyEventRepeatKey"/>
					<xsl:for-each select="./odm:FormData[@FormOID=$formVersionOID]">
						<xsl:variable name="formDataOID" select="@FormOID"/>
						<xsl:variable name="crfStatus" select="@OpenClinica:Status"/>
						<xsl:variable name="interviewerName" select="@OpenClinica:InterviewerName"/>
						<xsl:variable name="interviewDate" select="@OpenClinica:InterviewDate"/>
						<xsl:for-each select="./odm:ItemGroupData[@ItemGroupOID=$itemGroupRefOID]">
							<xsl:variable name="currentItemGrpDataNode" select="."/>
							<xsl:variable name="itemGroupRepeatKey" select="@ItemGroupRepeatKey"/>			
													
									insert into <xsl:value-of select="$tableName"/> (
									ssoid, ssid, study_event_oid 
									<xsl:if test="$studyEventOrdinal">
										,event_ordinal
									</xsl:if>
									,crf_version
									<xsl:if test="$eventStartDate">, event_start_date</xsl:if>
							<xsl:if test="$eventEndDate">, event_end_date</xsl:if>
							<xsl:if test="$eventStatus">, event_status</xsl:if>
							<xsl:if test="$eventLocation">, event_location</xsl:if>
							<xsl:if test="$subjectAgeAtEvent">, subject_age_at_event</xsl:if>
							<xsl:if test="$crfStatus">, crf_status</xsl:if>
							<xsl:if test="$interviewerName">, interviewerName</xsl:if>
							<xsl:if test="$interviewDate">, interviewDate</xsl:if>		
									, item_group_repeat_key
									, warehouse_insert_created_timestamp
									<xsl:for-each select="$itemGroupDef/odm:ItemRef">
								<!--<xsl:variable name="ItemOIDval" select="@ItemOID"/>-->
								<xsl:variable name="itemRefOID" select="@ItemOID"/>
								<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$itemRefOID]"/>
								<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
								<!-- old code
										<xsl:variable name="itemNamePre">
											<xsl:call-template name="string-replace-all">
												<xsl:with-param name="text" select="$itemDef/@Name"/>
												<xsl:with-param name="replace" select="' '"/>
												<xsl:with-param name="by" select="'_'"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="itemName">
											<xsl:call-template name="escape-special-sql-chars">
												<xsl:with-param name="dataValue"	select="$itemNamePre"/>
											</xsl:call-template>
										</xsl:variable>
										-->
								<!-- new code start -->
								<xsl:variable name="itemName">
									<xsl:call-template name="clean-up-identifier">
										<xsl:with-param name="text" select="$itemDef/@Name"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- new code end -->
								<xsl:variable name="isItemMultiSelect">
									<xsl:call-template name="is-item-multi-select">
										<xsl:with-param name="itemDef" select="$itemDef"/>
									</xsl:call-template>
								</xsl:variable>
								<!--<xsl:if test="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]">-->
								<xsl:for-each select="$currentItemGrpDataNode/odm:ItemData">
									<xsl:variable name="currentItemGrpDataNodeItemOID" select="@ItemOID"/>
									<xsl:variable name="itemValue" select="@Value"/>
									<xsl:variable name="isNullValue" select="@IsNull"/>
									<xsl:if test="$currentItemGrpDataNodeItemOID=$itemRefOID">
										<xsl:choose>
											<xsl:when test="$itemDef/@DataType = ('partialDate')">														
														,<xsl:call-template name="partial-date-min-val-col-name">
													<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
													<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
													<xsl:with-param name="itemName" select="$itemName"/>
												</xsl:call-template>														
														,<xsl:call-template name="partial-date-max-val-col-name">
													<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
													<!--<xsl:with-param name="itemOID" select="@ItemOID"/>-->
													<xsl:with-param name="itemName" select="$itemName"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:when test="$isItemMultiSelect='true'">
												<!-- For multi-select items insert the true/false into multiple columns created depending on values entered by user -->
												<!--<xsl:variable name="itemValue" select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@Value" /> -->
												<!-- 04/12/2010: Changes for "OpenClinica:MultiSelectListRef " child element in the definition of multi-select items -->
												<!--<xsl:variable name="codelistOID">													
															<xsl:call-template name="get-codelist-OID">														
																<xsl:with-param name="itemDef" select="$itemDef"/>														
															</xsl:call-template>												
														</xsl:variable>	-->
												<xsl:variable name="multiSelectListId">
													<xsl:call-template name="get-multi-select-list-id">
														<xsl:with-param name="itemDef" select="$itemDef"/>
													</xsl:call-template>
												</xsl:variable>
												<!-- generate the column names corresponding to multi-select value options selected by user -->
												<xsl:choose>
													<xsl:when test="$isNullValue = 'Yes'">
														<xsl:call-template name="get-multi-select-all-column-names">
															<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
															<!--<xsl:with-param name="itemOID" select="$itemRefOID"/>-->
															<xsl:with-param name="itemName" select="$itemName"/>
															<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
														</xsl:call-template>
													</xsl:when>
													<xsl:otherwise>
														<xsl:call-template name="get-multi-select-column-names-for-values-selected">
															<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
															<!--<xsl:with-param name="itemOID" select="$itemRefOID"/>-->
															<xsl:with-param name="itemName" select="$itemName"/>
															<xsl:with-param name="itemValue" select="$itemValue"/>
															<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
														</xsl:call-template>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>																										
														,
														<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
												<!-- <xsl:value-of select="@ItemOID"/>-->
												<xsl:value-of select="$itemName"/>
												<!--<xsl:if test="not(position()=last())">, </xsl:if>-->
											</xsl:otherwise>
										</xsl:choose>
										<!-- Check if the item is single select, only if the item is not multi-select -->
										<xsl:if test="$isItemMultiSelect='false'">
											<xsl:variable name="isItemSingleSelect">
												<xsl:call-template name="is-item-single-select">
													<xsl:with-param name="itemDef" select="$itemDef"/>
												</xsl:call-template>
											</xsl:variable>
											<xsl:if test="$isItemSingleSelect='true'">
												<!-- single-select items -->																												
														,<xsl:call-template name="get-col-name-single-select-label">
													<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
													<!--<xsl:with-param name="itemOID" select="@ItemOID">-->
													<xsl:with-param name="itemName" select="$itemName">
															</xsl:with-param>
												</xsl:call-template>
											</xsl:if>
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
							</xsl:for-each>								
									)
									values (		
									<!-- SSOID -->
									'<xsl:value-of select="$ssoid"/>',											
									<!-- SSID -->
									'<xsl:value-of select="$ssid"/>', 									
									<!-- Study Event OID -->
									'<xsl:value-of select="$studyEventOID"/>'									  
									<!-- Event Ordinal -->
							<xsl:if test="$studyEventOrdinal">
										,<xsl:value-of select="$studyEventOrdinal"/>
							</xsl:if>
							<!-- CRF version  --> 
									,'<xsl:value-of select="$formVersion"/>'
									<!-- Event Start Date -->
							<xsl:if test="$eventStartDate">,'<xsl:value-of select="$eventStartDate"/>' </xsl:if>
							<!-- Event End Date -->
							<xsl:if test="$eventEndDate">,'<xsl:value-of select="$eventEndDate"/>' </xsl:if>
							<!-- Event Status -->
							<xsl:if test="$eventStatus">,'<xsl:value-of select="$eventStatus"/>' </xsl:if>
							<!-- Event Location -->
							<xsl:if test="$eventLocation">,'<xsl:value-of select="$eventLocation"/>' </xsl:if>
							<!-- Subject age at an event -->
							<xsl:if test="$subjectAgeAtEvent">,'<xsl:value-of select="$subjectAgeAtEvent"/>' </xsl:if>
							<!-- CRF Status -->
							<xsl:if test="$crfStatus">,'<xsl:value-of select="$crfStatus"/>'</xsl:if>
							<!-- Interviewer name -->
							<xsl:if test="$interviewerName">,'<xsl:value-of select="$interviewerName"/>'</xsl:if>
							<!-- Interview date -->
							<xsl:if test="$interviewDate">,'<xsl:value-of select="$interviewDate"/>'</xsl:if>
							<!-- Item group repeat key -->
									,<xsl:value-of select="$itemGroupRepeatKey"/>
							<!-- last updated timestamp -->
									, '<xsl:value-of select="$now"/>'										
									<!-- non-repeating CRF Items -->
							<xsl:for-each select="$itemGroupDef/odm:ItemRef">
								<xsl:variable name="itemRefOID" select="@ItemOID"/>
								<xsl:variable name="itemDef" select="../../odm:ItemDef[@OID=$itemRefOID]"/>
								<xsl:variable name="isItemMultiSelect">
									<xsl:call-template name="is-item-multi-select">
										<xsl:with-param name="itemDef" select="$itemDef"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- Check if the item is single select -->
								<xsl:variable name="isItemSingleSelect">
									<xsl:call-template name="is-item-single-select">
										<xsl:with-param name="itemDef" select="$itemDef"/>
									</xsl:call-template>
								</xsl:variable>
								<!--<xsl:if test="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]">-->
								<xsl:for-each select="$currentItemGrpDataNode/odm:ItemData">
									<xsl:variable name="currentItemGrpDataNodeItemOID" select="@ItemOID"/>
									<xsl:variable name="itemValue" select="@Value"/>
									<xsl:if test="$currentItemGrpDataNodeItemOID=$itemRefOID">
										<!-- value of attribute 'IsNull' in the 'ItemData' element -->
										<xsl:variable name="isNullValue" select="@IsNull"/>
										<xsl:choose>
											<xsl:when test="$isNullValue = 'Yes'">
												<!-- Insert SQL NULL value in case value of attribute 'IsNull' in the 'ItemData' element is 'Yes' -->
												<xsl:choose>
													<xsl:when test="$itemDef/@DataType = ('partialDate')">
														<!-- insert null value for both the columns for partial date -->
																,null, null
															</xsl:when>
													<xsl:when test="$isItemMultiSelect='true'">
														<!-- insert null values for all the columns of multi-select item -->
														<!-- 04/12/2010: Changes for "OpenClinica:MultiSelectListRef " child element in the definition of multi-select items -->
														<!--<xsl:variable name="codelistOID">															
																	<xsl:call-template name="get-codelist-OID">																
																		<xsl:with-param name="itemDef" select="$itemDef"/>																
																	</xsl:call-template>														
																</xsl:variable>	-->
														<xsl:variable name="multiSelectListId">
															<xsl:call-template name="get-multi-select-list-id">
																<xsl:with-param name="itemDef" select="$itemDef"/>
															</xsl:call-template>
														</xsl:variable>
														<xsl:call-template name="get-multi-select-all-null-column-values">
															<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
														</xsl:call-template>
													</xsl:when>
													<xsl:otherwise>
																,null
															</xsl:otherwise>
												</xsl:choose>
												<!-- Insert value into label column for single select items -->
												<xsl:if test="$isItemSingleSelect='true'">
													<!-- insert null values into single-select item label column -->	
															,null											
														</xsl:if>
											</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
													<xsl:when test="$isItemMultiSelect='true'">
														<xsl:call-template name="get-multi-select-column-values">
															<xsl:with-param name="itemValue" select="$itemValue"/>
														</xsl:call-template>
													</xsl:when>
													<xsl:otherwise>
																,<xsl:if test="$itemDef/@DataType = 'date'">'</xsl:if>
														<xsl:if test="$itemDef/@DataType = ('text')">'</xsl:if>
														<!--<xsl:value-of select="$itemGroupData/odm:ItemData[@ItemOID=$itemRefOID]/@Value"/>-->
														<xsl:choose>
															<xsl:when test="$itemDef/@DataType = ('text')">
																<xsl:call-template name="escape-special-sql-chars">
																	<xsl:with-param name="dataValue" select="$itemValue"/>
																</xsl:call-template>
															</xsl:when>
															<xsl:when test="$itemDef/@DataType = ('partialDate')">
																<!-- get the min and maximum date values to be inserted for partial date item -->
																<xsl:call-template name="partial-date-min-date-val">
																	<xsl:with-param name="itemValue" select="$itemValue"/>
																</xsl:call-template>,												
																		<xsl:call-template name="partial-date-max-date-val">
																	<xsl:with-param name="itemValue" select="$itemValue"/>
																</xsl:call-template>
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of select="$itemValue"/>
															</xsl:otherwise>
														</xsl:choose>
														<xsl:if test="$itemDef/@DataType = 'date'">'</xsl:if>
														<xsl:if test="$itemDef/@DataType = ('text')">'</xsl:if>
													</xsl:otherwise>
												</xsl:choose>
												<!-- Insert value into label column for single select items -->
												<!-- Check if the item is single select, only if item is not multi-select -->
												<xsl:if test="$isItemMultiSelect='false'">
													<xsl:if test="$isItemSingleSelect='true'">
														<!-- single-select items -->
														<xsl:variable name="codeListOID">
															<xsl:call-template name="get-codelist-OID">
																<xsl:with-param name="itemDef" select="$itemDef"/>
															</xsl:call-template>
														</xsl:variable>													
																,'<xsl:call-template name="get-label-from-codelist">
															<xsl:with-param name="codelistOID" select="$codeListOID"/>
															<xsl:with-param name="itemValue" select="$itemValue"/>
														</xsl:call-template>'											
															</xsl:if>
												</xsl:if>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</xsl:for-each>
							</xsl:for-each>		
									);									
							</xsl:for-each>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	<!-- template to create the table for study subject listing table -->
	<xsl:template name="create-table-study-subject-listing">
		<xsl:param name="study-schema-name"/>		
				create table <xsl:value-of select="$study-schema-name"/>.study_subject_listing (			
				ssoid character varying(40),
				ssid character varying(40),
				subject_status character varying(255),
				subject_unique_id character varying(255),
				secondary_id character varying(255),
				date_of_birth date, 
				sex character(1),
				<!-- @pgawade 06/28/2010 Changed the character length to store study protocol name to character varying(255) to fix the issue #0005271. This length
				is set based on the "name" column data type in table "study" from the Open Clinica database -->
		<!--site_protocol_name character varying(30),-->
				site_protocol_name character varying(255),
				site_name character varying(255),
				warehouse_insert_created_timestamp timestamp with time zone);	
				ALTER TABLE <xsl:value-of select="$study-schema-name"/>.study_subject_listing ADD CONSTRAINT Pk_study_subject_listing PRIMARY KEY (ssoid, ssid);	
		</xsl:template>
	<!-- template to create the table for crf versions -->
	<xsl:template name="create-table-crf-version">
		<xsl:param name="study-schema-name"/>			
			create table <xsl:value-of select="$study-schema-name"/>.crf_version (
			crf_version_id serial NOT NULL,
			crf_name character varying(255),
			crf_version_name character varying(255),
			warehouse_insert_created_timestamp timestamp with time zone,
			CONSTRAINT Uk_crf_version_crf_version UNIQUE (crf_name, crf_version_name)
			);
		</xsl:template>
	<!-- template to get the minimun value date column for partial date item -->
	<xsl:template name="partial-date-min-val-col-name">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<!-- <xsl:param name="itemOID"/>	-->
		<xsl:param name="itemName"/>
		<!--<xsl:value-of select="$itemOID"/>_min -->
		<xsl:value-of select="$itemName"/>_min
		</xsl:template>
	<!-- template to get the maximum value date column for partial date item -->
	<xsl:template name="partial-date-max-val-col-name">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<!--<xsl:param name="itemOID"/> -->
		<xsl:param name="itemName"/>
		<!--<xsl:value-of select="$itemOID"/>_max	-->
		<xsl:value-of select="$itemName"/>_max
		</xsl:template>
	<!-- template to get minimum date value for partial date item -->
	<xsl:template name="partial-date-min-date-val">
		<xsl:param name="itemValue"/>
		<xsl:variable name="dash" select="'-'"/>
		<xsl:choose>
			<xsl:when test="contains($itemValue, $dash)">
				<xsl:variable name="beforeDash">
					<xsl:value-of select="substring-before($itemValue,$dash)"/>
				</xsl:variable>
				<xsl:variable name="afterDash">
					<xsl:value-of select="substring-after($itemValue,$dash)"/>
				</xsl:variable>
				<xsl:variable name="year" select="$beforeDash"/>
				<xsl:choose>
					<xsl:when test="contains($afterDash, $dash)">
						<!-- yyyy-mm-dd (dd-MMM-yyyy) -->
						<xsl:variable name="month" select="substring-before($afterDash,$dash)"/>
						<xsl:variable name="date" select="substring-after($afterDash,$dash)"/>
						<!-- Form the date object -->							
							'<xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="$date"/>'
						</xsl:when>
					<xsl:otherwise>
						<!-- yyyy-mm (MMM-yyyy) -->
						<xsl:variable name="month" select="$afterDash"/>
						<!-- date: first day of month -->
						<xsl:variable name="date" select="1"/>
						<!-- Form the date object -->							
							'<xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="$date"/>'
						</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- yyyy -->
				<xsl:variable name="year" select="$itemValue"/>
				<!-- month: January-->
				<xsl:variable name="month" select="01"/>
				<!-- date: 1st-->
				<xsl:variable name="date" select="01"/>
				<!-- Form the date object -->					
					'<xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="$date"/>'			
				</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to get maximum date value for partial date item -->
	<xsl:template name="partial-date-max-date-val">
		<xsl:param name="itemValue"/>
		<xsl:variable name="dash" select="'-'"/>
		<xsl:choose>
			<xsl:when test="contains($itemValue, $dash)">
				<xsl:variable name="beforeDash">
					<xsl:value-of select="substring-before($itemValue,$dash)"/>
				</xsl:variable>
				<xsl:variable name="afterDash">
					<xsl:value-of select="substring-after($itemValue,$dash)"/>
				</xsl:variable>
				<xsl:variable name="year" select="$beforeDash"/>
				<xsl:choose>
					<xsl:when test="contains($afterDash, $dash)">
						<!-- yyyy-mm-dd (dd-MMM-yyyy) -->
						<xsl:variable name="month" select="substring-before($afterDash,$dash)"/>
						<xsl:variable name="date" select="substring-after($afterDash,$dash)"/>
						<!-- Form the date object -->							
							'<xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="$date"/>'
						</xsl:when>
					<xsl:otherwise>
						<!-- yyyy-mm (MMM-yyyy) -->
						<xsl:variable name="month" select="$afterDash"/>
						<!-- date: last day of month -->
						<xsl:variable name="date">
							<xsl:call-template name="get-last-date-of-month">
								<xsl:with-param name="month" select="$month"/>
								<xsl:with-param name="year" select="$year"/>
							</xsl:call-template>
						</xsl:variable>
						<!-- Form the date object -->							
							'<xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="normalize-space($date)"/>' 								
						</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- yyyy -->
				<xsl:variable name="year" select="$itemValue"/>
				<!-- month: January-->
				<xsl:variable name="month" select="12"/>
				<!-- date: 31st-->
				<xsl:variable name="date" select="31"/>
				<!-- Form the date object -->					
					'<xsl:value-of select="$year"/>-<xsl:value-of select="$month"/>-<xsl:value-of select="$date"/>'			
				</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to get last date of a month -->
	<xsl:template name="get-last-date-of-month">
		<xsl:param name="month"/>
		<xsl:param name="year"/>
		<xsl:choose>
			<xsl:when test="$month = '01'">
						31
					</xsl:when>
			<xsl:when test="$month = '02'">
				<xsl:choose>
					<xsl:when test="($year mod 4) = 0">
								29
							</xsl:when>
					<xsl:otherwise>
								28
							</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$month = '03'">
						31
					</xsl:when>
			<xsl:when test="$month = '04'">
						30
					</xsl:when>
			<xsl:when test="$month = '05'">
						31
					</xsl:when>
			<xsl:when test="$month = '06'">
						30
					</xsl:when>
			<xsl:when test="$month = '07'">
						31
					</xsl:when>
			<xsl:when test="$month = '08'">
						31
					</xsl:when>
			<xsl:when test="$month = '09'">
						30
					</xsl:when>
			<xsl:when test="$month = '10'">
						31
					</xsl:when>
			<xsl:when test="$month = '11'">
						30
					</xsl:when>
			<xsl:when test="$month = '12'">
						31
					</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- template to check if the item is single select -->
	<!-- Single select items will have child element 'CodeListRef' without openclinica:IsMultiSelect="Yes"  -->
	<xsl:template name="is-item-single-select">
		<xsl:param name="itemDef"/>
		<xsl:variable name="isCodeListRefElement" select="$itemDef/odm:CodeListRef"/>
		<xsl:variable name="isMultiSelectRefElement" select="$itemDef/OpenClinica:MultiSelectListRef"/>
		<!--<xsl:variable name="isMultiSelect" select="$isCodeListRefElement/@OpenClinica:IsMultiSelect"/>-->
		<!-- Single select items will not have "OpenClinica:MultiSelectListRef" child element, but will have "CodeListRef" child element in its definition -->
		<!--<xsl:if test="$isCodeListRefElement">
				<xsl:choose>
					<xsl:when test="$isMultiSelect = 'Yes'">
						<xsl:value-of select="false()"/>-->
		<!-- item is multi-select -->
		<!--</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="true()"/>-->
		<!-- item is single-select -->
		<!--</xsl:otherwise>
				</xsl:choose>
			</xsl:if>-->
		<xsl:choose>
			<xsl:when test="$isMultiSelectRefElement">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$isCodeListRefElement">
					<xsl:value-of select="true()"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to check if the item is multi-select -->
	<!--Multi-select items will have child element 'CodeListRef' with openclinica:IsMultiSelect="Yes"  -->
	<xsl:template name="is-item-multi-select">
		<xsl:param name="itemDef"/>
		<!--<xsl:variable name="isCodeListRefElement" select="$itemDef/odm:CodeListRef"/>		-->
		<!-- Multi-select items will have "OpenClinica:MultiSelectListRef" child element in its definition -->
		<xsl:variable name="isMultiSelectRefElement" select="$itemDef/OpenClinica:MultiSelectListRef"/>
		<!--<xsl:variable name="isMultiSelect" select="$isCodeListRefElement/@OpenClinica:IsMultiSelect"/>-->
		<!--<xsl:if test="$isCodeListRefElement">
				<xsl:choose>
					<xsl:when test="$isMultiSelect = 'Yes'">
						<xsl:value-of select="true()"/>-->
		<!-- item is multi-select -->
		<!--</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()"/>-->
		<!-- item is single-select -->
		<!--</xsl:otherwise>
				</xsl:choose>
			</xsl:if>-->
		<xsl:choose>
			<xsl:when test="$isMultiSelectRefElement">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to get code list OID from the item definition -->
	<xsl:template name="get-codelist-OID">
		<xsl:param name="itemDef"/>
		<xsl:variable name="isCodeListRefElement" select="$itemDef/odm:CodeListRef"/>
		<xsl:if test="$isCodeListRefElement">
			<xsl:value-of select="$isCodeListRefElement/@CodeListOID"/>
		</xsl:if>
	</xsl:template>
	<!-- 04/12/2010 template to get the ID for multi-select list -->
	<xsl:template name="get-multi-select-list-id">
		<xsl:param name="itemDef"/>
		<xsl:variable name="isMultiSelectListRefElement" select="$itemDef/OpenClinica:MultiSelectListRef"/>
		<xsl:if test="$isMultiSelectListRefElement">
			<xsl:value-of select="$isMultiSelectListRefElement/@OpenClinica:MultiSelectListID"/>
		</xsl:if>
	</xsl:template>
	<!-- template to get column name for label text column for single select items -->
	<xsl:template name="get-col-name-single-select-label">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<!--<xsl:param name="itemOID"/>-->
		<xsl:param name="itemName"/>
		<!--<xsl:value-of select="$itemOID"/><xsl:text>_label</xsl:text>-->
		<xsl:value-of select="$itemName"/>
		<xsl:text>_label</xsl:text>
	</xsl:template>
	<!-- template to get data type for label text column for single select items -->
	<xsl:template name="get-col-data-type-single-select-label">
		<!-- Fixed the issue by changing the length of label text column for single select from character varying(30) to character varying(80) -->
		<!-- @pgawade 06/28/2010 Changed the character length to store the label for single select items while fixing issue #0005275 -->
		<xsl:text>character varying(255)</xsl:text>
	</xsl:template>
	<!-- template to get column name and data type for label text column for single select items -->
	<!--<xsl:template name="get-col-name-and-data-type-single-select-label">
			<xsl:param name="itemOID"/>			
			<xsl:call-template name="get-col-name-single-select-label">
				<xsl:with-param name="itemOID" select="$itemOID"/>
			</xsl:call-template><xsl:text> </xsl:text>character varying(30)
		</xsl:template>-->
	<!-- template to get label value from code list -->
	<xsl:template name="get-label-from-codelist">
		<xsl:param name="codelistOID"/>
		<xsl:param name="itemValue"/>
		<!--itemValue: *<xsl:value-of select="$itemValue"/>*
			codelistOID: <xsl:value-of select="$codelistOID"/>-->
		<xsl:variable name="codelist" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion/odm:CodeList[@OID = $codelistOID]"/>
		<xsl:variable name="codelistItem" select="$codelist/odm:CodeListItem[@CodedValue = $itemValue]"/>
		<!--TranslatedText: -->
		<!-- @ccollins 06/07/10 added escape-special-sql-chars function for column label values -->
		<!-- old code: <xsl:value-of select="$codelistItem/odm:Decode/odm:TranslatedText"/> -->
		<!--  new code: -->
		<xsl:call-template name="escape-special-sql-chars">
			<xsl:with-param name="dataValue" select="$codelistItem/odm:Decode/odm:TranslatedText"/>
		</xsl:call-template>
		<!-- end new code -->
		<!--codelist: <xsl:value-of select="$codelist/@OID "/>			
			codelistItem CodedValue: <xsl:value-of select="$codelistItem/@CodedValue"/>-->
	</xsl:template>
	<!-- template to get sub-string of a string before the last occurance of specified string  -->
	<xsl:template name="get-substring-before-last-occurance">
		<xsl:param name="text"/>
		<xsl:param name="token"/>
		<xsl:choose>
			<xsl:when test="contains($text, $token)">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="substring-before($text,$token)"/>
					<xsl:with-param name="replace" select="'-'"/>
					<xsl:with-param name="by" select="'_'"/>
				</xsl:call-template>
				<xsl:if test="contains(substring-after($text,$token), $token)">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$token"/>
						<xsl:with-param name="replace" select="'-'"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
					<xsl:call-template name="get-substring-before-last-occurance">
						<xsl:with-param name="text" select="substring-after($text,$token)"/>
						<xsl:with-param name="token" select="$token"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to get the sql syntax for column name and data type for multiple columns to be created for each multi-select item 
			Number of column to be created is equal to the number of items in the associated codelist. Each column name will include item OID and 
			and label of the CodeListItem -->
	<!-- 04/12/2010: Changed this template implementation to read "OpenClinica:MultiSelectList" element instead of "CodeList" element -->
	<xsl:template name="get-multi-select-columns-alter-table-statements">
		<!-- @ccollins 5/11/10 added schema param to support  drop column function -->
		<xsl:param name="schemaName"/>
		<xsl:param name="tableName"/>
		<xsl:param name="itemOID"/>
		<xsl:param name="multiSelectListId"/>
		<xsl:variable name="multiSelectList" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion/OpenClinica:MultiSelectList[@OpenClinica:ID = $multiSelectListId]"/>
		<xsl:for-each select="$multiSelectList/OpenClinica:MultiSelectListItem">
			<xsl:variable name="label">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
					<xsl:with-param name="replace" select="' '"/>
					<xsl:with-param name="by" select="'_'"/>
				</xsl:call-template>
			</xsl:variable>
			<!-- @ccollins 5/11/10 added special add column function that checks for existing column of same name before adding; as a (temporary?) fix to duplicates bug -->
			SELECT <xsl:value-of select="$schemaName"/>.add_table_field('<xsl:value-of select="$tableName"/>', '<xsl:value-of select="$itemOID"/>
			<xsl:text>_</xsl:text>
			<xsl:call-template name="escape-special-sql-chars">
				<xsl:with-param name="dataValue" select="$label"/>
			</xsl:call-template>
			<xsl:text> boolean</xsl:text> default false;');
<!-- old code:
			Alter table <xsl:value-of select="$tableName"/> add column <xsl:value-of select="$itemOID"/><xsl:text>_</xsl:text><xsl:call-template name="escape-special-sql-chars">
														<xsl:with-param name="dataValue" select="$label"/>
														</xsl:call-template><xsl:text> boolean</xsl:text> default false;
-->
		</xsl:for-each>
	</xsl:template>
	<!-- template to get the sql syntax for alter table to add multi-select item 
			Number of column to be created is equal to the number of items in the associated codelist. Each column name will include item OID and 
			and label of the CodeListItem -->
	<xsl:template name="get-multi-select-column-names-with-data-type">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<!-- <xsl:param name="itemOID"/> -->
		<xsl:param name="itemName"/>
		<xsl:param name="multiSelectListId"/>
		<xsl:variable name="multiSelectList" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion/OpenClinica:MultiSelectList[@OpenClinica:ID = $multiSelectListId]"/>
		<xsl:for-each select="$multiSelectList/OpenClinica:MultiSelectListItem">
			<xsl:variable name="label">
				<!-- @pgawade 06/24/2010 Used the template "" to clean up identifiers for invalid characters to avoid the SQL exception -->
				<!-- old code: 	
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
						<xsl:with-param name="replace" select="' '"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				-->
				<!-- new code start -->
				<xsl:call-template name="clean-up-identifier">
					<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
				</xsl:call-template>
				<!-- new code end -->
			</xsl:variable>
			<!-- @ccollins 06/07/10 changed escape function to use escape-special-sql-chars-column-name() instead of escape-special-sql-chars() b/c latter does not handle dashes -->
			<!--<xsl:value-of select="$itemOID"/>-->
			<xsl:value-of select="$itemName"/>
			<xsl:text>_</xsl:text>
			<!-- old code <xsl:call-template name="escape-special-sql-chars-column-name">
																									<xsl:with-param name="columnName" select="$label"/>
																								</xsl:call-template>-->
			<!-- new code start -->
			<xsl:value-of select="$label"/>
			<!-- new code end  -->
			<xsl:text> boolean default false</xsl:text>
			<xsl:if test="not(position()=last())">, </xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!-- template to get all column names associated with a muli-select item -->
	<xsl:template name="get-multi-select-all-column-names">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<!--<xsl:param name="itemOID"/>-->
		<xsl:param name="itemName"/>
		<xsl:param name="multiSelectListId"/>
		<xsl:variable name="multiSelectList" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion/OpenClinica:MultiSelectList[@OpenClinica:ID = $multiSelectListId]"/>
		<xsl:for-each select="$multiSelectList/OpenClinica:MultiSelectListItem">
			<xsl:variable name="label">
				<!-- @pgawade 06/24/2010 Used the template "" to clean up identifiers for invalid characters to avoid the SQL exception -->
				<!-- old code
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
						<xsl:with-param name="replace" select="' '"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				-->
				<!-- new code start -->
				<xsl:call-template name="clean-up-identifier">
					<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
				</xsl:call-template>
				<!-- new code end -->
			</xsl:variable>
			<!-- @ccollins 06/07/10 changed escape function to use escape-special-sql-chars-column-name() instead of escape-special-sql-chars() b/c latter does not handle dashes --> 
				,<!--<xsl:value-of select="$itemOID"/>-->
			<xsl:value-of select="$itemName"/>
			<xsl:text>_</xsl:text>
			<!-- old code <xsl:call-template name="escape-special-sql-chars-column-name">
																									<xsl:with-param name="columnName" select="$label"/>
																								</xsl:call-template>-->
			<!-- new code start -->
			<xsl:value-of select="$label"/>
			<!-- new code end -->
			<!--<xsl:if test="not(position()=last())">, </xsl:if>	-->
		</xsl:for-each>
	</xsl:template>
	<!-- template to get the column names associated with multi-select item depending on value options selected by user -->
	<xsl:template name="get-multi-select-column-names-for-values-selected">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<!--<xsl:param name="itemOID"/>-->
		<xsl:param name="itemName"/>
		<xsl:param name="multiSelectListId"/>
		<xsl:param name="itemValue"/>
		<xsl:variable name="multiSelectList" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion/OpenClinica:MultiSelectList[@OpenClinica:ID = $multiSelectListId]"/>
		<xsl:choose>
			<xsl:when test="contains($itemValue, ',')">
				<xsl:variable name="value" select="substring-before($itemValue, ',')"/>
				<xsl:call-template name="get-multi-select-column-name-for-value-selected">
					<xsl:with-param name="multiSelectList" select="$multiSelectList"/>
					<xsl:with-param name="value" select="$value"/>
					<!--<xsl:with-param name="itemOID" select="$itemOID"/>-->
					<xsl:with-param name="itemName" select="$itemName"/>
				</xsl:call-template>
				<xsl:call-template name="get-multi-select-column-names-for-values-selected">
					<!--<xsl:with-param name="itemOID" select="$itemOID"/>-->
					<xsl:with-param name="itemName" select="$itemName"/>
					<xsl:with-param name="multiSelectListId" select="$multiSelectListId"/>
					<xsl:with-param name="itemValue" select="substring-after($itemValue, ',')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="get-multi-select-column-name-for-value-selected">
					<xsl:with-param name="multiSelectList" select="$multiSelectList"/>
					<xsl:with-param name="value" select="$itemValue"/>
					<!--<xsl:with-param name="itemOID" select="$itemOID"/>-->
					<xsl:with-param name="itemName" select="$itemName"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to get the column name for value option selected for multi-select item -->
	<xsl:template name="get-multi-select-column-name-for-value-selected">
		<!-- @pgawade 05/06/2010 Changed the item column name to be item name instead of item OID temporarily -->
		<xsl:param name="multiSelectList"/>
		<xsl:param name="value"/>
		<!--<xsl:param name="itemOID"/>-->
		<xsl:param name="itemName"/>
		<xsl:for-each select="$multiSelectList/OpenClinica:MultiSelectListItem">
			<xsl:if test="@CodedValue = $value">
				<xsl:variable name="label">
					<!-- @pgawade 06/24/2010 Used the template "clean-up-identifier" to clean up identifiers for invalid characters to avoid the SQL exception -->
					<!-- old code 
						<xsl:call-template name="string-replace-all">
							<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
							<xsl:with-param name="replace" select="' '"/>
							<xsl:with-param name="by" select="'_'"/>
						</xsl:call-template>
					-->
					<!-- new code start -->
					<xsl:call-template name="clean-up-identifier">
						<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
					</xsl:call-template>
					<!-- new code end -->
				</xsl:variable>
				<!-- @ccollins 06/07/10 changed escape function to use escape-special-sql-chars-column-name() instead of escape-special-sql-chars() b/c latter does not handle dashes --> 
					,<!--<xsl:value-of select="$itemOID"/>-->
				<xsl:value-of select="$itemName"/>
				<xsl:text>_</xsl:text>
				<!-- old code <xsl:call-template name="escape-special-sql-chars-column-name">
																										<xsl:with-param name="columnName" select="$label"/>
																									</xsl:call-template>-->
				<!-- new code start -->
				<xsl:value-of select="$label"/>
				<!-- new code end -->
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	<!-- template to get boolean true column values for multi-select item column depending on the value options chosen by user-->
	<xsl:template name="get-multi-select-column-values">
		<xsl:param name="itemValue"/>
		<xsl:choose>
			<xsl:when test="contains($itemValue, ',')">
					,true
					<xsl:call-template name="get-multi-select-column-values">
					<xsl:with-param name="itemValue" select="substring-after($itemValue, ',')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
					,true
				</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to get null values for all codelist items associated with a multi-select item -->
	<xsl:template name="get-multi-select-all-null-column-values">
		<xsl:param name="multiSelectListId"/>
		<xsl:variable name="multiSelectList" select="/odm:ODM/odm:Study[1]/odm:MetaDataVersion/OpenClinica:MultiSelectList[@OpenClinica:ID = $multiSelectListId]"/>
		<xsl:for-each select="$multiSelectList/OpenClinica:MultiSelectListItem">
					, null
				</xsl:for-each>
	</xsl:template>
	<!-- template to get multi-select item column name -->
	<!--<xsl:template name="get-col-name-multi-select">
			<xsl:param name="itemOID"/>
			<xsl:param name="codelistOID"/>
			
			<xsl:variable name="label">					
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="./odm:Decode/odm:TranslatedText"/>
					<xsl:with-param name="replace" select="' '"/>
					<xsl:with-param name="by" select="'_'"/>
				</xsl:call-template>
					
			</xsl:variable>
 @ccollins 06/07/10 changed escape function to use escape-special-sql-chars-column-name() instead of escape-special-sql-chars() b/c latter does not handle dashes 
			<xsl:value-of select="$itemOID"/><xsl:text>_</xsl:text><xsl:call-template name="escape-special-sql-chars-column-name">
																									<xsl:with-param name="columnName" select="$label"/>
																								</xsl:call-template>
		</xsl:template>-->
	<!-- template to get the data type for multi-select column -->
	<!--<xsl:template name="get-col-data-type-multi-select">
			<xsl:text>boolean</xsl:text>
		</xsl:template>-->
	<!-- template to create crf status summary table -->
	<xsl:template name="create-crf-status-summary-table">
		<xsl:param name="study-schema-name"/>
		<!--<xsl:param name="crf-status-summary-table-name"/>-->
			
			CREATE TABLE <xsl:value-of select="$study-schema-name"/>.<xsl:value-of select="$crf-status-summary-table-name"/> (
			crf_status_summary_id serial,
			site_name character varying(255),
			ssoid character varying(40),	
			ssid character varying(40),
			study_event_oid character varying(40),
			event_ordinal integer DEFAULT 1,
			crf_name character varying(255),
			crf_version character varying(255),			
			<!-- integer columns for CRF status -->
		<!-- @pgawade 06/24/2010 Used the template "" to clean up identifiers for invalid characters to avoid the SQL exception -->
		<!-- old code
			crf_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$crfStatusInitialDataEntryStarted"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,
			crf_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$crfStatusDoubleDataEntryStarted"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,
			crf_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$crfStatusCompleted"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,
			crf_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$crfStatusLocked"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,								
			crf_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$crfStatusInitialDataEntryCompleted"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,
			-->
		<!-- new code start -->				
            crf_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$crfStatusInitialDataEntryStarted"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,
			crf_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$crfStatusDoubleDataEntryStarted"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,
			crf_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$crfStatusCompleted"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,
			crf_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$crfStatusLocked"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,								
			crf_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$crfStatusInitialDataEntryCompleted"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,  
			<!-- new code end -->
		<!-- integer columns for event status -->
		<!-- old code
			event_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$eventStatusDataEntryStarted"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,							
			event_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$eventStatusCompleted"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,
			event_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$eventStatusSigned"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,			
			event_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$eventStatusSkipped"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,
			event_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$eventStatusStopped"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer,							
			event_status_<xsl:call-template name="string-replace-all">
								<xsl:with-param name="text" select="$eventStatusLocked"/>
								<xsl:with-param name="replace" select="' '"/>
								<xsl:with-param name="by" select="'_'"/>
							</xsl:call-template><xsl:text> </xsl:text> integer																																		
			);		
			-->
		<!-- new code start -->
			event_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$eventStatusDataEntryStarted"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,							
			event_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$eventStatusCompleted"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,
			event_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$eventStatusSigned"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,			
			event_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$eventStatusSkipped"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,
			event_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$eventStatusStopped"/>
		</xsl:call-template>
		<xsl:text> </xsl:text> integer,							
			event_status_<xsl:call-template name="clean-up-identifier">
			<xsl:with-param name="text" select="$eventStatusLocked"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>  integer,
			warehouse_insert_created_timestamp timestamp with time zone);
			<!-- new code end -->
	</xsl:template>
	<!--
	<xsl:template name="create-foreign-key-ssoid-ssid">
		<xsl:param name="tableNameWithoutSchema"/>
		<xsl:param name="study-schema-name"/>
		
		<xsl:variable name="cleanedTableName">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$tableNameWithoutSchema"/>
			</xsl:call-template>
		</xsl:variable>		
			ALTER TABLE <xsl:value-of select="normalize-space($study-schema-name)"/>.<xsl:value-of select="
			normalize-space($cleanedTableName)"/> ADD CONSTRAINT Fk_ssoid_ssid_<xsl:value-of select="
			normalize-space($cleanedTableName)"/> FOREIGN KEY (ssoid, ssid) REFERENCES <xsl:value-of select="
			$study-schema-name"/>.study_subject_listing;			
	</xsl:template>
	-->
	<!-- temp removed by tbh -->
	<xsl:template name="create-foreign-key-crf-version">
		<xsl:param name="tableNameWithoutSchema"/>
		<xsl:param name="study-schema-name"/>
		
		<xsl:variable name="cleanedTableName">
			<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$tableNameWithoutSchema"/>
			</xsl:call-template>
		</xsl:variable>		
			ALTER TABLE <xsl:value-of select="normalize-space($study-schema-name)"/>.<xsl:value-of select="
			normalize-space($cleanedTableName)"/> ADD CONSTRAINT Fk_crf_version_<xsl:value-of select="
			normalize-space($cleanedTableName)"/> FOREIGN KEY (crf_version) REFERENCES <xsl:value-of 
			select="$study-schema-name"/>.crf_version (crf_version_name);			
	</xsl:template>
	
	<!-- template to collect and insert data into crf_status_summary table -->
	<xsl:template name="collect-and-insert-data-into-crf-status-summary-table">
		<xsl:param name="formVersion"/>
		<xsl:param name="formVersionOID"/>
		<xsl:param name="crfName"/>
		<xsl:param name="study-schema-name"/>
		<xsl:param name="now"/>
		
		<xsl:for-each select="/odm:ODM/odm:ClinicalData">
			<xsl:variable name="siteOID" select="@StudyOID"/>
			<xsl:variable name="siteStudyElement" select="/odm:ODM/odm:Study[@OID = $siteOID]"/>
			<xsl:variable name="studyName" select="$siteStudyElement/odm:GlobalVariables/odm:StudyName"/>
			<xsl:variable name="spaceDashSpace" select="'&#x20;-&#x20;'"/>
			<xsl:variable name="siteName">
				<xsl:value-of select="substring-after($studyName,$spaceDashSpace)"/>
			</xsl:variable>
			<xsl:for-each select="./odm:SubjectData">
				<xsl:variable name="ssoid" select="@SubjectKey"/>
				<xsl:variable name="ssid" select="@OpenClinica:StudySubjectId"/>
				<xsl:for-each select="./odm:StudyEventData">
					<xsl:variable name="studyEventOID" select="@StudyEventOID"/>
					<!--<xsl:variable name="eventStartDate" select="@OpenClinica:StartDate" />
						<xsl:variable name="eventEndDate" select="@OpenClinica:EndDate" />
						<xsl:variable name="eventLocation" select="@OpenClinica:StudyEventLocation" />
						<xsl:variable name="subjectAgeAtEvent" select="@OpenClinica:SubjectAgeAtEvent" />-->
					<xsl:variable name="eventStatus" select="@OpenClinica:Status"/>
					<!-- Value for study event ordinal -->
					<xsl:variable name="studyEventOrdinal" select="@StudyEventRepeatKey"/>
					<xsl:for-each select="./odm:FormData[@FormOID=$formVersionOID]">
						<!--<xsl:variable name="formDataOID" select="@FormOID"/>-->
						<xsl:variable name="crfStatus" select="@OpenClinica:Status"/>
						<!-- Insert data into raw data table -->
						<!--<xsl:if test="$siteName != ''">-->
						<xsl:call-template name="insert-data-crf-status-summary-table">
							<xsl:with-param name="study-schema-name" select="$study-schema-name"/>
							<!--<xsl:with-param name="crf-status-summary-table-name" select="$crf-status-summary-table-name"/>-->
							<xsl:with-param name="siteName" select="$siteName"/>
							<xsl:with-param name="ssoid" select="$ssoid"/>
							<xsl:with-param name="ssid" select="$ssid"/>
							<!-- @pgawade 07/20/2010 Added the value of event ordinal -->
							<xsl:with-param name="eventOrdinal" select="$studyEventOrdinal"/>
							<xsl:with-param name="seoid" select="$studyEventOID"/>
							<xsl:with-param name="crfName" select="$crfName"/>
							<xsl:with-param name="crfVersion" select="$formVersion"/>
							<xsl:with-param name="crfStatus" select="$crfStatus"/>
							<xsl:with-param name="eventStatus" select="$eventStatus"/>
							<!-- @pgawade	07/20/2010 Added parameter with current timestamp -->
							<xsl:with-param name="now" select="$now"/>
						</xsl:call-template>
						<!--</xsl:if>	-->
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	<!-- template to insert record into crf_status_summary table -->
	<xsl:template name="insert-data-crf-status-summary-table">
		<xsl:param name="study-schema-name"/>
		<!--<xsl:param name="crf-status-summary-table-name"/>-->
		<xsl:param name="siteName"/>
		<xsl:param name="ssoid"/>
		<xsl:param name="ssid"/>
		<xsl:param name="seoid"/>
		<xsl:param name="eventOrdinal"/>
		<xsl:param name="crfName"/>
		<xsl:param name="crfVersion"/>
		<xsl:param name="crfStatus"/>
		<xsl:param name="eventStatus"/>
		<xsl:param name="now"/>
						
			INSERT INTO <xsl:value-of select="$study-schema-name"/>.<xsl:value-of select="$crf-status-summary-table-name"/> 
			(<xsl:if test="$siteName != ''">
				site_name,
			</xsl:if>	
			ssoid,
			<xsl:if test="$ssid">
				ssid,
			</xsl:if>
			study_event_oid,
			<xsl:if test="$eventOrdinal">
				event_ordinal,
			</xsl:if>	
			crf_name,
			crf_version
			<xsl:if test="$crfStatus">	
				,			
				<!-- Boolean columns for CRF status -->
			<!-- @pgawade 06/24/2010 Used the template "" to clean up identifiers for invalid characters to avoid the SQL exception -->
			<!-- old code
				crf_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$crfStatusInitialDataEntryStarted"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,
				crf_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$crfStatusDoubleDataEntryStarted"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,
				crf_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$crfStatusCompleted"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,
				crf_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$crfStatusLocked"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,								
				crf_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$crfStatusInitialDataEntryCompleted"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>
                -->
			<!-- new code start -->
                crf_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$crfStatusInitialDataEntryStarted"/>
			</xsl:call-template>,
				crf_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$crfStatusDoubleDataEntryStarted"/>
			</xsl:call-template>,
				crf_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$crfStatusCompleted"/>
			</xsl:call-template>,
				crf_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$crfStatusLocked"/>
			</xsl:call-template>,								
				crf_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$crfStatusInitialDataEntryCompleted"/>
			</xsl:call-template>
			<!-- new code end -->
		</xsl:if>
		<xsl:if test="$eventStatus">	
				,				
				<!-- Boolean columns for event status -->
			<!-- old code
				event_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$eventStatusDataEntryStarted"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,							
				event_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$eventStatusCompleted"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,
				event_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$eventStatusSigned"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,			
				event_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$eventStatusSkipped"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,
				event_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$eventStatusStopped"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>,							
				event_status_<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$eventStatusLocked"/>
									<xsl:with-param name="replace" select="' '"/>
									<xsl:with-param name="by" select="'_'"/>
								</xsl:call-template>
				-->
			<!-- new code start -->
				event_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$eventStatusDataEntryStarted"/>
			</xsl:call-template>,							
				event_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$eventStatusCompleted"/>
			</xsl:call-template>,
				event_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$eventStatusSigned"/>
			</xsl:call-template>,			
				event_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$eventStatusSkipped"/>
			</xsl:call-template>,
				event_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$eventStatusStopped"/>
			</xsl:call-template>,							
				event_status_<xsl:call-template name="clean-up-identifier">
				<xsl:with-param name="text" select="$eventStatusLocked"/>
			</xsl:call-template>
		</xsl:if>	
			<!-- @pgawade 07/20/2010 Added the column warehouse_insert_created_timestamp -->				
				,warehouse_insert_created_timestamp				
				<!-- new code end -->
																																											
			)
			VALUES
			(	<xsl:if test="$siteName != ''">
					'<xsl:call-template name="escape-special-sql-chars">
				<xsl:with-param name="dataValue" select="$siteName"/>
			</xsl:call-template>',				
				</xsl:if>	
				'<xsl:value-of select="$ssoid"/>',
				<xsl:if test="$ssid">					
					'<xsl:value-of select="$ssid"/>',
				</xsl:if>	
				'<xsl:value-of select="$seoid"/>',
				<xsl:if test="$eventOrdinal">
			<xsl:value-of select="$eventOrdinal"/>,
				</xsl:if>
				'<xsl:value-of select="$crfName"/>',
				'<xsl:value-of select="$crfVersion"/>'
				<xsl:if test="$crfStatus">
					,
					<xsl:choose>
				<xsl:when test="$crfStatus = $crfStatusInitialDataEntryStarted">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$crfStatus = $crfStatusDoubleDataEntryStarted">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$crfStatus = $crfStatusCompleted">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$crfStatus = $crfStatusLocked">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$crfStatus = $crfStatusInitialDataEntryCompleted">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$eventStatus">	
					,											
					<xsl:choose>
				<xsl:when test="$eventStatus = $eventStatusDataEntryStarted">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$eventStatus = $eventStatusCompleted">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$eventStatus = $eventStatusSigned">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$eventStatus = $eventStatusSkipped">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$eventStatus = $eventStatusStopped">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>,
					<xsl:choose>
				<xsl:when test="$eventStatus = $eventStatusLocked">
							1
						</xsl:when>
				<xsl:otherwise>
							0
						</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!-- @pgawade 07/20/2010 Added the value for column warehouse_insert_created_timestamp -->
				,'<xsl:value-of select="$now"/>'
			);
		</xsl:template>
	<!-- Other utility templates -->
	<xsl:template name="string-replace-all">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:value-of select="$by"/>
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="substring-after($text,$replace)"/>
					<xsl:with-param name="replace" select="$replace"/>
					<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to escape the special characters in SQL -->
	<xsl:template name="escape-special-sql-chars">
		<xsl:param name="dataValue"/>
		<xsl:variable name="single-quote" select="&quot;'&quot;"/>
		<xsl:variable name="back-slash" select="'\'"/>
		<!--not used: <xsl:variable name="colun" select="':'"/>			-->
		<xsl:variable name="double-single-quote" select="&quot;''&quot;"/>
		<xsl:variable name="double-back-slash" select="'\\'"/>
		<xsl:choose>
			<xsl:when test="contains($dataValue, $single-quote)">
				<!-- replace single quote with double single quote -->
				<!--data value <xsl:value-of select="$dataValue"/> contains single quote-->
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$dataValue"/>
					<xsl:with-param name="replace" select="$single-quote"/>
					<xsl:with-param name="by" select="$double-single-quote"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($dataValue, $back-slash)">
				<!-- replace back-slash with double back-slash -->
				<!--data value <xsl:value-of select="$dataValue"/> contains back-slash-->
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$dataValue"/>
					<xsl:with-param name="replace" select="$back-slash"/>
					<xsl:with-param name="by" select="$double-back-slash"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$dataValue"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- @ccollins 06/07/10 added function escape-special-sql-chars-column-name(); currently just calls escape-special-sql-chars-table-name
	Note: This template can be removed after testing this commit as it is not called from any where. Instead the newly added template 
			"clean-up-identifier" is been used to clean all the identifiers used for ad-hoc reporing database generation. 
	-->
	<xsl:template name="escape-special-sql-chars-column-name">
		<xsl:param name="columnName"/>
		<xsl:call-template name="escape-special-sql-chars-table-name">
			<xsl:with-param name="tableName" select="$columnName"/>
		</xsl:call-template>
	</xsl:template>
	<!-- template to remove special sql characters not allowed in table names -->
	<!-- @pgawade 06/24/2010 Added the check to see if the invalid characters is present in the string or not before replaving the same 
			Note: This template can be removed after testing this commit as it is not called from any where. Instead the newly added template 
			"clean-up-identifier" is been used to clean all the identifiers used for ad-hoc reporing database generation. -->
	<xsl:template name="escape-special-sql-chars-table-name">
		<xsl:param name="tableName"/>
		<!-- step1: table name = replace '-'(dash) in the name with '_'(under score) -->
		<xsl:variable name="tableName1">
			<xsl:choose>
				<xsl:when test="contains($tableName, '-')">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName"/>
						<xsl:with-param name="replace" select="'-'"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step2: table name = replace ' '(space) in the name with '_'(under score) -->
		<xsl:variable name="tableName2">
			<xsl:choose>
				<xsl:when test="contains($tableName1, ' ')">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName1"/>
						<xsl:with-param name="replace" select="' '"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step3: table name =  replace colon with empty string (remove colon) -->
		<xsl:variable name="tableName3">
			<xsl:choose>
				<xsl:when test="contains($tableName2, ':')">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName2"/>
						<xsl:with-param name="replace" select="':'"/>
						<xsl:with-param name="by" select="''"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName2"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step4: table name =  replace '(' with empty string (remove '(') -->
		<xsl:variable name="tableName4">
			<xsl:choose>
				<xsl:when test="contains($tableName3, '(')">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName3"/>
						<xsl:with-param name="replace" select="'('"/>
						<xsl:with-param name="by" select="''"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName3"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step5: table name =  replace ')' with empty string (remove ')') -->
		<xsl:variable name="tableName5">
			<xsl:choose>
				<xsl:when test="contains($tableName4, ')')">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName4"/>
						<xsl:with-param name="replace" select="')'"/>
						<xsl:with-param name="by" select="''"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName4"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step6: table name =  replace Apostrophe with '_'(under score) -->
		<xsl:variable name="apostrophe" select='"&apos;"'/>
		<xsl:variable name="tableName6">
			<xsl:choose>
				<xsl:when test="contains($tableName5, $apostrophe)">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName5"/>
						<xsl:with-param name="replace" select="$apostrophe"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName5"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step7: table name =  replace back-slash with '_'(under score) -->
		<xsl:variable name="back-slash" select="'\'"/>
		<xsl:variable name="tableName7">
			<xsl:choose>
				<xsl:when test="contains($tableName6, '\')">
					<xsl:call-template name="string-replace-all">
						<xsl:with-param name="text" select="$tableName6"/>
						<xsl:with-param name="replace" select="$back-slash"/>
						<xsl:with-param name="by" select="'_'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tableName6"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- step7: table name =  replace '.' with underscore -->
		<xsl:choose>
			<xsl:when test="contains($tableName7, '.')">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$tableName7"/>
					<xsl:with-param name="replace" select="'.'"/>
					<xsl:with-param name="by" select="'_'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tableName7"/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- step8: table name =  replace starting numbers with empty string (remove starting numbers) -->
		<!--<xsl:call-template name="remove-starting-numbers-from-string">
				<xsl:with-param name="text" select="$tableName5"/>				
			</xsl:call-template>		-->
	</xsl:template>
	<!-- template to remove starting numbers in the string -->
	<xsl:template name="remove-starting-numbers-from-string">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="normalize-space((substring($text, 1, 1))) != 'NaN'">
				<xsl:variable name="textAppendedWithStartNumber">
					<xsl:value-of select="substring($text, 2)"/>
					<xsl:value-of select="substring($text, 1, 1)"/>
				</xsl:variable>
				<xsl:call-template name="remove-starting-numbers-from-string">
					<xsl:with-param name="text" select="$textAppendedWithStartNumber"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template to prefix starting digit with ID_ in the string -->
	<xsl:template name="prefix-starting-digit-with-ID_">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="normalize-space((substring($text, 1, 1))) != 'NaN'">
				<xsl:text>ID_</xsl:text>
				<xsl:value-of select="$text"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="clean-up-identifier">
		<xsl:param name="text"/>
		<!-- 1. Replace all characters outside the ranges 0-9, A-Z, and a-z with underscores.-->
		<xsl:variable name="invalid-chars-replaced">
			<!--<xsl:call-template name="escape-special-sql-chars-table-name">
					<xsl:with-param name="tableName" select="$text"/>					
				</xsl:call-template>	-->
			<xsl:call-template name="replace-invalid-char">
				<xsl:with-param name="text" select="normalize-space($text)"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- 2. Escape the special SQL characters -->
		<!--<xsl:variable name="special-chars-escaped">
				<xsl:call-template name="escape-special-sql-chars">
					<xsl:with-param name="dataValue" select="$invalid-chars-replaced"/>
				</xsl:call-template>
			</xsl:variable>-->
		<!-- 3. Prefix starting digit with ID_ -->
		<xsl:call-template name="prefix-starting-digit-with-ID_">
			<xsl:with-param name="text" select="$invalid-chars-replaced"/>
		</xsl:call-template>
	</xsl:template>
	<!-- template to replace all characters outside the ranges 0-9, A-Z, and a-z with underscores -->
	<xsl:template name="replace-invalid-char">
		<xsl:param name="text"/>
		<!-- check if the string has character(s) outside the range 0-9, A-Z or a-z -->
		<xsl:choose>
			<xsl:when test='matches($text, "[^0-9A-Za-z]")'>
				<!--String has character(s) outside the range 0-9, A-Z or a-z!-->
				<!-- iterate through each character of the string and replace characters outside the ranges 0-9, A-Z, and a-z with underscores -->
				<xsl:value-of select='replace(normalize-space($text), "[^0-9A-Za-z]", "_")'/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($text)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- template tp return the character from a parameter string at a specified index in another parameter -->
	<!-- <xsl:template name="get-char-at-index">
			<xsl:param name="text"/>
			<xsl:param name="index"/>
			
			<xsl:variable name="char-to-test">
				<xsl:value-of select="sub-string($text, $index, 1)"/>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test='matches($char-to-test, "^[0-9A-Za-z")'>
					
					
				</xsl:when>
				<xsl:otherwise>
					
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:template>-->
	<xsl:template name="Newline">
		<xsl:text>&#10;
			</xsl:text>
	</xsl:template>
</xsl:stylesheet>
