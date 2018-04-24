mvn clean package 打包
mvn clean package  -Dmaven.test.skip=true 不测试打包
mvn clean install
deploy 将项目导入本地 提供其他项目依赖

<build>
        <finalName>multi-common</finalName>
        <plugins>
            <plugin>
                <inherited>true</inherited>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <executions>
                    <execution>
                        <id>attach-sources</id>
                        <goals>
                            <goal>jar</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

    <distributionManagement>
        <repository>
            <id>localRepository</id>
            <url>file:E:/work/maven/localWareHouse</url>
        </repository>
    </distributionManagement>