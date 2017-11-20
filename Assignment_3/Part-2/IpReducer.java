package Cloud.ApacheLog;

import java.io.IOException;
import java.util.Iterator;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;

/**
 * Counts all of the hits for an ip. Outputs all ip's
 */
public class IpReducer extends MapReduceBase implements Reducer<Text, IntWritable,IntWritable, Text > 
{
//this place is just change the key's place, and the key is still the ip.
  public void reduce(Text ip, Iterator<IntWritable> counts,
      OutputCollector<IntWritable,Text> output, Reporter reporter)
      throws IOException {
    
    int totalCount = 0;
    
    // loop over the count and tally it up
    while (counts.hasNext())
    {
      IntWritable count = counts.next();
      totalCount += count.get();
    }
    if(totalCount>=100){
        output.collect(new IntWritable(totalCount),new Text(ip));
    }
  }

}
