package org.akaza.openclinica.dao.core;

import org.akaza.openclinica.bean.extract.ExtractPropertyBean;
import org.akaza.openclinica.bean.service.PdfProcessingFunction;
import org.akaza.openclinica.bean.service.SasProcessingFunction;
import org.akaza.openclinica.bean.service.SqlProcessingFunction;
import org.akaza.openclinica.exception.OpenClinicaSystemException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.context.ResourceLoaderAware;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Properties;

public class CoreResources implements ResourceLoaderAware   {

    private ResourceLoader resourceLoader;
    public static String PROPERTIES_DIR;
    private static String DB_NAME;
    private static Properties DATAINFO;
    private static Properties EXTRACTINFO;

    private Properties dataInfo;
    private Properties extractInfo;

    protected final Logger logger = LoggerFactory.getLogger(getClass().getName());
    // private MessageSource messageSource;
    private static ArrayList<ExtractPropertyBean> extractProperties;

    public void setResourceLoader(ResourceLoader resourceLoader)  {
        this.resourceLoader = resourceLoader;
        try {
            // setPROPERTIES_DIR();
            String dbName = dataInfo.getProperty("dataBase");
            DATAINFO = dataInfo;
            EXTRACTINFO = extractInfo;

            
            DB_NAME = dbName;
            SQLFactory factory = SQLFactory.getInstance();
            factory.run(dbName, resourceLoader);
            copyBaseToDest(resourceLoader);
            extractProperties = findExtractProperties();
        } catch (OpenClinicaSystemException e) {
        	logger.debug(e.getMessage());
        	logger.debug(e.toString());
             throw new OpenClinicaSystemException(e.getMessage(), e.fillInStackTrace());
        } catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    private void copyBaseToDest(ResourceLoader resourceLoader)  {
    //	System.out.println("Properties directory?"+resourceLoader.getResource("properties/xslt"));
    
    	ByteArrayInputStream listSrcFiles[] = new ByteArrayInputStream[10];
    	String[] fileNames =  {"odm_spss_dat.xsl","ODMToTAB.xsl","odm_to_html.xsl","odm_to_xslfo.xsl","ODMReportStylesheet.xsl","ODMReportStylesheet.xsl","ODMToCSV.xsl","ODM-XSLFO-Stylesheet.xsl","odm_spss_sps.xsl"};
    	try{
    listSrcFiles[0] = (ByteArrayInputStream) resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[0]).getInputStream();
    listSrcFiles[1] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[1]).getInputStream();
    listSrcFiles[2] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[2]).getInputStream();
    listSrcFiles[3] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[3]).getInputStream();
    listSrcFiles[4] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[4]).getInputStream();
    listSrcFiles[5] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[5]).getInputStream();
    listSrcFiles[6] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[6]).getInputStream();
    listSrcFiles[7] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[7]).getInputStream();
    listSrcFiles[8] = (ByteArrayInputStream)resourceLoader.getResource("classpath:properties"+File.separator+"xslt"+File.separator+fileNames[8]).getInputStream();
    	}catch(IOException ioe){
    		OpenClinicaSystemException oe = new OpenClinicaSystemException("Unable to read source files");
    		oe.initCause(ioe);
    		oe.setStackTrace(ioe.getStackTrace());
    		logger.debug(ioe.getMessage());
    		throw oe;
    	}
    //File src = resourceLoader.getResource("classpath:properties/xslt/odm_spss_dat.xsl").getFile().getParentFile();
	File dest = new File(getField("filePath")+"xslt");
//if(src.isDirectory()){
		if(!dest.exists()){
			if(!dest.mkdirs()){
				throw new OpenClinicaSystemException("Copying files, Could not create direcotry: " + dest.getAbsolutePath() + ".");
			}
		}
	//}
	 //String list[] = listSrcFiles;
	              //copy all the files in the list.
                for (int i = 0; i < fileNames.length; i++)
                {
                        File dest1 = new File(dest,fileNames[i]);
                      //  File src1 = listSrcFiles[i];
                        if(listSrcFiles[i]!=null)
                        copyFiles(listSrcFiles[i],dest1);
                }
	
		
	}

    private void copyFiles(ByteArrayInputStream fis,File dest){
    	//FileInputStream fis = null;
    	FileOutputStream fos = null;
    	byte[] buffer = new byte[512]; //Buffer 4K at a time (you can change this).
    	int bytesRead;
    	logger.debug("fis?"+fis);
    	try{
    		//fis = new FileInputStream(src);
    		fos = new FileOutputStream(dest);
    		 while (( bytesRead = fis.read(buffer)) >= 0) {
    			                                 fos.write(buffer,0,bytesRead);
    			                         }
    	}catch(IOException ioe){//error while copying files
    		OpenClinicaSystemException oe = new OpenClinicaSystemException("Unable to copy file: " +  fis + "to" + dest.getAbsolutePath()+"."  + dest.getAbsolutePath() + ".");
    		oe.initCause(ioe);
    		oe.setStackTrace(ioe.getStackTrace());
    		throw oe;
    	}
    	finally { //Ensure that the files are closed (if they were open).
    		                        if (fis != null) { try {
										fis.close();
									} catch (IOException ioe) {
										OpenClinicaSystemException oe = new OpenClinicaSystemException("Unable to copy file: " + fis  + "to" + dest.getAbsolutePath()+"."  + dest.getAbsolutePath() + ".");
							    		oe.initCause(ioe);
							    		oe.setStackTrace(ioe.getStackTrace());
							    		logger.debug(ioe.getMessage());
							    		throw oe;
										
									} }
    		                    if (fos != null) { try {
									fos.close();
								} catch (IOException ioe) {
									OpenClinicaSystemException oe = new OpenClinicaSystemException("Unable to copy file: " + fis + "to" + dest.getAbsolutePath()+"."  + dest.getAbsolutePath() + ".");
						    		oe.initCause(ioe);
						    		oe.setStackTrace(ioe.getStackTrace());
						    		logger.debug(ioe.getMessage());
						    		throw oe;
									
								} }
    		               }
    }
	public ResourceLoader getResourceLoader() {
        return resourceLoader;
    }

    // public MessageSource getMessageSource() {
    // return messageSource;
    // }
    //
    // public void setMessageSource(MessageSource messageSource) {
    // this.messageSource = messageSource;
    // }

    public static ArrayList<ExtractPropertyBean> getExtractProperties() {
        return extractProperties;
    }

    public void setExtractProperties(ArrayList extractProperties) {
        this.extractProperties = extractProperties;
    }

    private ArrayList<ExtractPropertyBean> findExtractProperties() throws OpenClinicaSystemException{
        ArrayList<ExtractPropertyBean> ret = new ArrayList<ExtractPropertyBean>();
        
        // ExtractPropertyBean epbean = new ExtractPropertyBean();
        int i = 1;
        while (!getExtractField("extract." + i+".file").equals("")) {
            ExtractPropertyBean epbean = new ExtractPropertyBean();
            epbean.setId(i);
            // we will implement a find by id function in the front end
            
            //check to make sure the file exists, if not throw an exception and system will abort to start.
            checkForFile(getExtractFields("extract." + i+".file"));
            epbean.setFileName(getExtractFields("extract." + i+".file"));
            // file name of the xslt stylesheet
            epbean.setFiledescription(getExtractField("extract." + i+".fileDescription"));
            // description of the choice of format
            epbean.setHelpText(getExtractField("extract." + i+".helptext"));
            // help text, currently in the alt-text of the link
            epbean.setLinkText(getExtractField("extract." + i+".linkText"));
            // link text of the choice of format
            // epbean.setRolesAllowed(getExtractField("xsl.allowed." + i).split(","));
            // which roles are allowed to see the choice?
            epbean.setFileLocation(getExtractField("extract." + i+".location"));
            // destination of the copied files
            // epbean.setFormat(getExtractField("xsl.format." + i));
            // if (("").equals(epbean.getFormat())) {
            
            epbean.setFormat("oc1.3");
            // }
            // formatting choice. currently permenantly set at oc1.3
            epbean.setExportFileName(getExtractFields("extract." + i+".exportname"));
            // destination file name of the copied files
            String whichFunction = getExtractField("extract."+i+".post").toLowerCase();
            // post-processing event after the creation
            // System.out.println("found post function: " + whichFunction);
   
            //added by JN: Zipformat comes from extract properties returns true by default
            epbean.setZipFormat(getExtractFieldBoolean("extract."+i+".zip"));
            epbean.setDeleteOld(getExtractFieldBoolean("extract."+i+".deleteOld"));
            epbean.setSuccessMessage(getExtractField("extract."+i+".success"));
            epbean.setFailureMessage(getExtractField("extract."+i+".failure"));
            
            if ("sql".equals(whichFunction)) {
                // set the bean within, so that we can access the file locations etc
                SqlProcessingFunction function = new SqlProcessingFunction(epbean);
                String whichSettings = getExtractField("xsl.post." + i + ".sql");
                if (!"".equals(whichSettings)) {
                    function.setDatabaseType(getExtractField(whichSettings + ".dataBase").toLowerCase());
                    function.setDatabaseUrl(getExtractField(whichSettings + ".url"));
                    function.setDatabaseUsername(getExtractField(whichSettings + ".username"));
                    function.setDatabasePassword(getExtractField(whichSettings + ".password"));
                } else {
                    // set default db settings here
                    function.setDatabaseType(getField("dataBase"));
                    function.setDatabaseUrl(getField("url"));
                    function.setDatabaseUsername(getField("username"));
                    function.setDatabasePassword(getField("password"));
                }
                // also pre-set the database connection stuff
                epbean.setPostProcessing(function);
                // System.out.println("found db password: " + function.getDatabasePassword());
            } else if ("pdf".equals(whichFunction)) {
                // TODO add other functions here
                epbean.setPostProcessing(new PdfProcessingFunction());
            } else if ("sas".equals(whichFunction)) {
                epbean.setPostProcessing(new SasProcessingFunction());
            }else if(!whichFunction.isEmpty()){
            	String postProcessorName = getExtractField(whichFunction+".postProcessor");
            	if(postProcessorName.equals("pdf")){
            		epbean.setPostProcessing(new PdfProcessingFunction());
            		epbean.setPostProcDeleteOld(getExtractFieldBoolean(whichFunction+".deleteOld"));
            		epbean.setPostProcZip(getExtractFieldBoolean(whichFunction+".zip"));
            		epbean.setPostProcLocation(getExtractField(whichFunction+".location"));
            		epbean.setPostProcExportName(getExtractField(whichFunction+".exportName"));
            	}
            	else if(postProcessorName.equals("sql")){
            		
            	}
            	 
            }
            else {
                // add a null here
                epbean.setPostProcessing(null);
            }
            ret.add(epbean);
            i++;
        }

        System.out.println("found " + ret.size() + " records in extract.properties");
        return ret;
    }

    private void checkForFile(String[] extractFields) throws OpenClinicaSystemException{
	
		int cnt = extractFields.length;
		int i = 0;
		//iterate through all comma separated file names
		while(i<cnt){
			
				File f = new File(getField("filePath") + "xslt" + File.separator +extractFields[i]);		
				System.out.println(getField("filePath") + "xslt" + File.separator +extractFields[i]);
				if(!f.exists()) throw new OpenClinicaSystemException("FileNotFound -- Please make sure"+ extractFields[i]+ "exists");

	
			i++;
			
		}
		
	}

	public InputStream getInputStream(String fileName) throws IOException {
        return resourceLoader.getResource("classpath:properties/" + fileName).getInputStream();
    }

    public URL getURL(String fileName) throws IOException {
        return resourceLoader.getResource("classpath:properties/" + fileName).getURL();
    }

    public File getFile(String fileName) {
        try {
            InputStream inputStream = getInputStream(fileName);
            File f = new File(fileName);
            OutputStream outputStream = new FileOutputStream(f);
            byte buf[] = new byte[1024];
            int len;
            try {
                while ((len = inputStream.read(buf)) > 0)
                    outputStream.write(buf, 0, len);
            } finally {
                outputStream.close();
                inputStream.close();
            }
            return f;

        } catch (IOException e) {
            throw new OpenClinicaSystemException(e.getMessage(), e.fillInStackTrace());
        }
    }

    public void setPROPERTIES_DIR() {
        String resource = "classpath:properties/placeholder.properties";
        System.out.println("Resource" + resource);
        Resource scr = resourceLoader.getResource(resource);
        String absolutePath = null;
        try {
            // System.out.println("Resource" + resource);
            absolutePath = scr.getFile().getAbsolutePath();
            // System.out.println("Resource" + ((ClassPathResource) scr).getPath());
            // System.out.println("Resource" + resource);
            PROPERTIES_DIR = absolutePath.replaceAll("placeholder.properties", "");
            System.out.println("Resource" + PROPERTIES_DIR);
        } catch (IOException e) {
            throw new OpenClinicaSystemException(e.getMessage(), e.fillInStackTrace());
        }

    }

    public static String getDBName() {
        return DB_NAME;
    }

    public static String getField(String key) {
        String value = DATAINFO.getProperty(key);
        if (value != null) {
            value = value.trim();
        }
        return value == null ? "" : value;

    }

    // TODO internationalize
    public static String getExtractField(String key) {
        String value = EXTRACTINFO.getProperty(key);
        if (value != null) {
            value = value.trim();
        }
        return value == null ? "" : value;
    }

    //JN:The following method returns default of true when converting from string
    public static boolean getExtractFieldBoolean(String key) {
        String value = EXTRACTINFO.getProperty(key);
        if (value != null) {
            value = value.trim();
        }
        if(value==null)
        	return true;//Defaulting to true
        if(value.equalsIgnoreCase("false"))
        return false;
        else
        	return true;//defaulting to true
        
    }
    public static String[] getExtractFields(String key) {
        String value = EXTRACTINFO.getProperty(key);
        if (value != null) {
            value = value.trim();
        }
        return value.split(",");
    }
    public static ExtractPropertyBean findExtractPropertyBeanById(int id) {
        for (ExtractPropertyBean epbean : extractProperties) {
            if (epbean.getId() == id) {
                return epbean;
            }
        }
        return null;
    }

    public Properties getDataInfo() {
        return dataInfo;
    }

    public void setDataInfo(Properties dataInfo) {
        this.dataInfo = dataInfo;
    }

    public Properties getExtractInfo() {
        return extractInfo;
    }

    public void setExtractInfo(Properties extractInfo) {
        this.extractInfo = extractInfo;
    }

}
