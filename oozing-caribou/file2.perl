use Template::Caribou::Tags::Hive ':all';

workflow 'demo-wf',
    start => 'cleanup-node',
    end => 'end',
    sub {

    action 'cleanup-node',
        ok => 'fork-node',
        error => 'fail',
        sub {
            fs {
                oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo';
            }
    };

    oozie_fork 'fork-node', qw/
        pig-node
        streaming-node
    /;


    action 'pig-node',
        ok => 'join-node',
        error => 'fail',
        sub { pig
            'job-tracker' => '${JobTracker}',
            'name-node' => '${nameNode}',
            prepare => sub {
                oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node';
            },
            configuration => {
                'mapred.job.queue.name' => '${queueName}',
                'mapred.map.output.compress' => 'false',
            },
            script => 'id.pig',
            params => [
            'INPUT=/user/${wf:user()}/${examplesRoot}/input-data/text',
            'OUTPUT=/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node'
            ],
    };


    action 'streaming-node',
        ok => 'join-node',
        error => 'fail',
        sub {
        map_reduce
            job_tracker => '${JobTracker}',
            name_node => '${nameNode}',
            prepare => sub {
                delete => '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node'
            },
            streaming => {
                mapper => '/bin/cat',
                reducer => '/usr/bin/wc',
            },
            configuration => {
                'mapred.job.queue.name' => '${queueName}',
                'mapred.input.dir' => '/user/${wf:user()}/${examplesRoot}/input-data/text',
                'mapred.output.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node'
            },
        ;
    };

    oozie_join 'join-node' => 'mr-node';

    action 'mr-node',
        ok => 'decision-node',
        error => 'fail',
        sub {
            map_reduce
                job_tracker => '${JobTracker}',
                name_node => '${nameNode}',
                prepare => sub {
                    oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node';
                },
                configuration => {
                    'mapred.job.queue.name' => '${queueName}',
                    'mapred.mapper.class' => 'org.apache.oozie.example.DemoMapper',
                    'mapred.mapoutput.key.class' => 'org.apache.hadoop.io.Text',
                    'mapred.mapoutput.value.class' => 'org.apache.hadoop.io.IntWritable',
                    'mapred.reducer.class' => 'org.apache.oozie.example.DemoReducer',
                    'mapred.map.tasks' => 1,
                    'mapred.input.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node,/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node',
                    'mapred.output.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node'
                },
        };

    decision 'decision-node', 'end',
        'hdfs-node' => q[${fs:exists(concat(concat(concat(concat(concat(nameNode, '/user/'), wf:user()), '/'), examplesRoot), '/output-data/demo/mr-node')) == "true"}];

    action 'hdfs-node',
        ok => 'end',
        error => 'fail',
        sub {
        fs {
            move '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/final-data';
        };
    };

    oozie_kill 'fail' => <<'URGH';
Demo workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]
URGH

};
