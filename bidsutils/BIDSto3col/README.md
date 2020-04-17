
Contributed by Tom Nichols. See attached for BIDSto3col.sh.  From the help...

```
Usage: BIDSto3col.sh [options] BidsTSV OutBase 

Reads BidsTSV and then creates 3 column event files, one per event
type if a "trial_type" column is found.  Files are named as OutBase
and, if "trial_type" is present, appended with the event name. 
By default, all rows and event types are used, and the height value
(3rd column) is 1.0.   

Options
  -s             Even if "trial_type" column is found, ignore and process
                 all rows as a single event type.
  -e EventName   Instead of all event types, only use the given event
                 type (no event name appended to OutBase). 
  -E EventName   Same as -e, except output file name does not have
                 EventName appended.
  -h HtColName   Instead of using 1.0, get height value from given
                 column; two files are written, the unmodulated (with
                 1.0 in 3rd column) and the modulated one, having a
                 "_pmod" suffix. 
  -d DurColName  Instead of getting duration from the "duration"
                 column, take it from this named column.
  -t TypeColName Instead of getting trial type from "trial_type"
                 column, use this column.
  -b Sec         Shift onset times backwards, subtracting specified
                 value (in seconds) from each onset. (Useful when
                 initial acquistions are discarded).
  -N             By default, when creating 3 column files any spaces
                 in the event name are replaced with "$SpaceReplace";
                 use this option to suppress this replacement.
```

Here's a demo...

```
  $ BIDSto3col.sh ds001/sub-13/func/sub-13_task-balloonanalogrisktask_run-01_events.tsv /tmp/duh
  Creating '/tmp/duh_cash_demean.txt'...
  Creating '/tmp/duh_cash_fixed_real_RT.txt'...
  Creating '/tmp/duh_control_pumps_demean.txt'...
  Creating '/tmp/duh_control_pumps_fixed_real_RT.txt'...
  Creating '/tmp/duh_explode_demean.txt'...
  Creating '/tmp/duh_pumps_demean.txt'...
  Creating '/tmp/duh_pumps_fixed_real_RT.txt'...
  $ BIDSto3col.sh -e cash_demean ds001/sub-13/func/sub-13_task-balloonanalogrisktask_run-01_events.tsv /tmp/duh
  Creating '/tmp/duh_cash_deman.txt'...
  $ BIDSto3col.sh -e cash_demean -h explode_demean ds001/sub-13/func/sub-13_task-balloonanalogrisktask_run-01_events.tsv /tmp/duh
  Creating '/tmp/duh_cash_demean.txt'...
  	WARNING: Event 'cash_demean' has non-numeric heights from 'explode_demean'
```

Note that it checks for non-numeric heights (and missing event names and/or column names).
