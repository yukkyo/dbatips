docker run --name OraDB12cR2 \
--shm-size=5g \
-p 1521:1521 -p 5500:5500 \
-e ORACLE_SID=oracle \
-e ORACLE_PDB=oracle_pdb \
-e ORACLE_PWD=Fujimoto_DBA \
-v /Users/fujimotoyuusuke/Documents/OracleDB_Image:/u01/app/oracle/oradata \
oracle/database:12.2.0.1-ee
