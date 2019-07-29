#!/usr/bin/env rdmd

import std;

void main()
{
    auto joblist = usersJobList();
    if(joblist.length < 10) {
        writefln!"# Your jobs:\n%-(\t%s\n%)"(joblist);
    } else {
        writefln!"# Your jobs: %s"(joblist.length);
    }
    writeln();


    auto nodes = getNodesInfo().sort!"a.name < b.name"();

    writeln("# Used logical CPUs by your jobs:");
    size_t totalCPUs;
    size_t totalNodes;
    foreach(n; nodes) {
        size_t cnt = n.slots.filter!(a => joblist.canFind(a.jobId)).walkLength;
        if(cnt != 0) {
            writefln!"\t%s: %s/%s"(n.name, cnt, n.ncpus);
            totalCPUs += cnt;
            totalNodes += 1;
        }
    }
    writeln();

    writefln!"# Total: %s nodes and %s logical CPUs are used by your jobs."(totalNodes, totalCPUs);
    writeln();

    writeln("# qgroup -l:");
    writeln(executeCommand(["qgroup", "-l"]));
}


struct Node
{
    struct Slot
    {
        uint slotId;
        string jobId;
    }

    string name;
    size_t ncpus;
    string queue;
    Slot[] slots;
}


/++
pbsnodes -aから出力される情報を整理します
+/
Node[] getNodesInfo()
{
    Node[] nodeList;
    foreach(info; executeCommand(["pbsnodes", "-a"]).splitLines().map!strip.splitter(""))
    {
        if(info.length == 0) continue;

        Node node;

        node.name = info[0];

        if(auto value = info.getFieldValue("jobs")) {
            foreach(slotInfo; value.splitter(',').map!strip.map!`a.findSplit("/")`) {
                Node.Slot slot;

                slot.slotId = slotInfo[2].to!uint;
                slot.jobId = slotInfo[0].normalizeJobId;
                node.slots ~= slot;
            }
        }

        if(auto value = info.getFieldValue("resources_available.ncpus")) {
            node.ncpus = value.to!uint;
        }

        if(auto value = info.getFieldValue("queue")) {
            node.queue = value;
        }

        nodeList ~= node;
    }

    return nodeList;
}


/++
qstat -aでユーザーのジョブのリストを返します
+/
string[] usersJobList()
{
    auto qstat = executeCommand(["qstat", "-a"]).splitLines();

    if(qstat.length <= 3)
        return [];
    
    qstat = qstat[3 .. $];
    return qstat.map!(a => a.split()[0].normalizeJobId).array();
}


string executeCommand(string[] commands)
{
    auto res = execute(commands);
    enforce(res.status == 0, `Commands '%s' is failed with status=%s`.format(commands, res.status));

    return res.output;
}


string getFieldValue(Range)(Range lines, string key)
{
    auto res = lines.find!(a => a.startsWith(key));
    if(res.empty)
        return null;
    
    return res.front.findSplitAfter("=")[1].strip;
}


string normalizeJobId(string jobid)
{
    return jobid.findSplitBefore(".jb")[0].findSplitBefore("[")[0];
}
