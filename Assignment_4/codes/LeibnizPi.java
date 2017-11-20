import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapred.*;

import java.io.IOException;
import java.util.Iterator;
import java.util.StringTokenizer;

public class LeibnizPi {
    public static class PiMap extends MapReduceBase implements Mapper<LongWritable,Text,Text,IntWritable> {
        private IntWritable N = new IntWritable();
        private String one = "1000000";
        public void map(LongWritable key, Text value, OutputCollector<Text, IntWritable> output, Reporter reporter) throws IOException {

            String line = value.toString();
            StringTokenizer tokenizer = new StringTokenizer(line);
            int num = Integer.parseInt(tokenizer.nextToken());
            for(int i=0;i<=num;i++)
            {
                N.set(i);
                output.collect(new Text(one), N);
            }
        }
    }

    public static class PiReduce extends MapReduceBase implements Reducer<Text, IntWritable, Text, DoubleWritable> {
        public void reduce(Text key, Iterator<IntWritable> values, OutputCollector<Text, DoubleWritable> output, Reporter reporter) throws IOException {
            double sum = 0;
            int getNum=0;
            while (values.hasNext()) {
                getNum=values.next().get();
                sum += Math.pow((-1),getNum) / (2 * getNum + 1);
            }
            output.collect(key, new DoubleWritable(4*sum));
        }
    }

    public static void main(String[] args) throws Exception {
        JobConf conf = new JobConf(LeibnizPi.class);
        conf.setJobName("Leibniz-Pi");

        conf.setMapperClass(PiMap.class);
        conf.setMapOutputKeyClass(Text.class);
        conf.setMapOutputValueClass(IntWritable.class);
        conf.setReducerClass(PiReduce.class);
        conf.setOutputKeyClass(Text.class);
        conf.setOutputValueClass(DoubleWritable.class);

        FileInputFormat.setInputPaths(conf, new Path(args[0]));
        FileOutputFormat.setOutputPath(conf, new Path(args[1]));

        JobClient.runJob(conf);
    }
}
