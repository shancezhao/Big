package Cloud.ApacheLog;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Iterator;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.io.WritableComparable;

import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;
import org.apache.hadoop.io.WritableComparator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Runner {

    /**
     * @param args
     */
   
    public static void main(String[] args) throws Exception {
        JobConf conf = new JobConf(Runner.class);
        Path tempDir = new Path("IPcount");

        conf.setJobName("ip-count");

        conf.setMapperClass(IpMapper.class);

        conf.setMapOutputKeyClass(Text.class);//ip(text),count
        conf.setMapOutputValueClass(IntWritable.class);

        conf.setOutputKeyClass(IntWritable.class);
        conf.setOutputValueClass(Text.class);
        conf.setReducerClass(IpReducer.class);  //int,text

        // take the input and output from the command line
        FileInputFormat.setInputPaths(conf, new Path(args[0]));
        FileOutputFormat.setOutputPath(conf, tempDir);

        JobClient.runJob(conf);

        //change
        JobConf sortConf = new JobConf(Runner.class);
        sortConf.setJobName("ip-sort");
        sortConf.setMapperClass(Map.class);//count(IntWritable),ip(text)
        sortConf.setMapOutputKeyClass(IntWritable.class);//count(IntWritable),ip(text)
        sortConf.setMapOutputValueClass(Text.class);
        //   sortConf.setReducerClass(IpReducer.class);
        FileInputFormat.setInputPaths(sortConf, tempDir);

        sortConf.setOutputKeyComparatorClass(IntComparator.class);    
        sortConf.setOutputKeyClass(Text.class);
        sortConf.setOutputValueClass(IntWritable.class);
        sortConf.setReducerClass(Reduce.class);
        FileOutputFormat.setOutputPath(sortConf, new Path(args[1]));
        JobClient.runJob(sortConf);
    }

    public static class IntComparator extends WritableComparator {

        public IntComparator() {
            super(IntWritable.class);
        }

        @Override
        public int compare(byte[] b1, int s1, int l1, byte[] b2, int s2, int l2) {
            Integer v1 = ByteBuffer.wrap(b1, s1, l1).getInt();
            Integer v2 = ByteBuffer.wrap(b2, s2, l2).getInt();
            return v1.compareTo(v2) * (-1);
        }
    }
}

