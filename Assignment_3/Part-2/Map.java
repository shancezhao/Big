package Cloud.ApacheLog;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reporter;

/**
 * Mapper that takes a line from an Apache access log and emits the IP with a
 * count of 1. This can be used to count the number of times that a host has hit
 * a website.
 */
public class Map extends MapReduceBase
        implements Mapper<LongWritable, Text,IntWritable, Text> {

    public void map(LongWritable fileOffset, Text values,
            OutputCollector<IntWritable,Text> output, Reporter reporter)
            throws IOException {

        String line = values.toString();
        String[] tokens = line.split("\\s"); // Delimiter
        String valueIp = tokens[1].toString();
        int keyCount = Integer.parseInt(tokens[0].replaceAll("\\s+",""));
        output.collect(new IntWritable(keyCount), new Text(valueIp));
    }

}
