*"* use this source file for any macro definitions you need
*"* in the implementation part of the class

define mac_task_begin.
  me->log_task_begin( i_task = &1
                      i_text = &2 ).
end-of-definition.

define mac_task_begin_data.
  me->log_task_begin( i_task = &1
                      i_text = &2
                      i_data = &3 ).
end-of-definition.

define mac_update_task_begin.
  me->log_update_task_begin( i_task = &1
                             i_data = &2 ).
end-of-definition.

define mac_task_end.
  me->log_task_end( i_task = &1 ).
end-of-definition.

define mac_task_end_data.
  me->log_task_end( i_task = &1
                    i_data = &2 ).
end-of-definition.
