<project xmlns="com.autoesl.autopilot.project" name="bubble_sort" top="bubble">
    <includePaths/>
    <libraryPaths/>
    <Simulation>
        <SimFlow name="csim" csimMode="0" lastCsimMode="0"/>
    </Simulation>
    <files xmlns="">
        <file name="../bubble_tb.c" sc="0" tb="1" cflags=" -Wno-unknown-pragmas -Wno-unknown-pragmas" csimflags=" -Wno-unknown-pragmas" blackbox="false"/>
        <file name="bubble_sort/bubble.c" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
        <file name="bubble_sort/bubble.h" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
    </files>
    <solutions xmlns="">
        <solution name="bubbleHLS" status="active"/>
    </solutions>
</project>

