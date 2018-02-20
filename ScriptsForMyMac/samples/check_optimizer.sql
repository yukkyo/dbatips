select
	table_name
	, num_rows
	, blocks
	, last_analyzed
from
	dba_tab_statistics
where
	owner = upper('&&1')
	and table_name = upper('&&2')
;
