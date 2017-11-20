import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.*;

import java.io.IOException;
import java.util.Iterator;
import java.util.StringTokenizer;

public class FindFactorial {
    public static class FactorialMap extends MapReduceBase implements Mapper<LongWritable,Text,Text,IntWritable> {

        private IntWritable number = new IntWritable();
        private String one = "50";
        public void map(LongWritable key, Text value, OutputCollector<Text, IntWritable> output, Reporter reporter) throws IOException {
            String line = value.toString();
            StringTokenizer tokenizer = new StringTokenizer(line);
            /*
            *   When the input file has 1-50 numbers
            *
            */
//            while(tokenizer.hasMoreTokens()) {
//                number.set(Integer.parseInt(tokenizer.nextToken()));
//                output.collect(new Text(one), number);
//            }
            int num=Integer.parseInt(tokenizer.nextToken());
            for(int i=1;i<=num;i++)
            {
                number.set(i);
                output.collect(new Text(one), number);
            }
            }
        }

    public static class FactorialReduce extends MapReduceBase implements Reducer<Text, IntWritable, Text, DoubleWritable> {
        public void reduce(Text key, Iterator<IntWritable> values, OutputCollector<Text, DoubleWritable> output, Reporter reporter) throws IOException {
            double sum = 1;
            while (values.hasNext()) {
                sum *= values.next().get();
            }
            output.collect(key, new DoubleWritable(sum));
        }
    }

    public static void main(String[] args) throws Exception {
        JobConf conf = new JobConf(FindFactorial.class);
        conf.setJobName("find-factorial");

        conf.setMapperClass(FactorialMap.class);
        conf.setMapOutputKeyClass(Text.class);
        conf.setMapOutputValueClass(IntWritable.class);
        conf.setReducerClass(FactorialReduce.class);
        conf.setOutputKeyClass(Text.class);
        conf.setOutputValueClass(DoubleWritable.class);

        FileInputFormat.setInputPaths(conf, new Path(args[0]));
        FileOutputFormat.setOutputPath(conf, new Path(args[1]));

        JobClient.runJob(conf);
    }
}
