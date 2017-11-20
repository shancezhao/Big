package Cloud.ApacheLog;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;

import java.io.IOException;
import java.util.Iterator;

public class Reduce extends MapReduceBase implements Reducer<IntWritable, Text, Text, IntWritable> {
    public void reduce(IntWritable key, Iterator<Text> list, OutputCollector<Text, IntWritable> output, Reporter reporter) throws IOException {
        for (Iterator<Text> it = list; it.hasNext(); ) {
            Text value = it.next();

            output.collect(new Text(value), key);

        }
    }

}
