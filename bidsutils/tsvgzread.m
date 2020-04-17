function [out_arr] = tsvgzread(filename)
    fileStream = java.io.FileInputStream(filename);
    gzipStream = java.util.zip.GZIPInputStream(fileStream);
    buffer = java.io.ByteArrayOutputStream();
    org.apache.commons.io.IOUtils.copy(gzipStream, buffer);
    gzipStream.close();
    
    output = buffer.toString();
    out_arr =  str2num(output);
end
