"! <p class="shorttext synchronized" lang="en">Factory for creating search queries</p>
CLASS zcl_adcoset_search_query_fac DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Creates query instance</p>
      create_query
        IMPORTING
          parallel_processing TYPE zif_adcoset_ty_global=>ty_parl_processing OPTIONAL
          scope               TYPE REF TO zif_adcoset_search_scope
          settings            TYPE zif_adcoset_ty_global=>ty_search_settings_int
        RETURNING
          VALUE(result)       TYPE REF TO zif_adcoset_search_query
        RAISING
          zcx_adcoset_static_error.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_adcoset_search_query_fac IMPLEMENTATION.


  METHOD create_query.
    DATA: task_runner TYPE REF TO zif_adcoset_parl_task_runner.

    IF parallel_processing-enabled = abap_true.
      TRY.
          task_runner = zcl_adcoset_parl_task_runner=>new(
            server_group   = parallel_processing-server_group
*           task_prefix    =
*           max_tasks      = 10
            " TODO: move handler_class/handler_method to parallel settings???
            handler_class  = 'ZCL_ADCOSET_SEARCH_ENGINE'
            handler_method = 'SEARCH_CODE_IN_PACKAGE' ).
        CATCH zcx_adcoset_static_error ##needed.
      ENDTRY.
    ENDIF.

    result = COND #(
      WHEN task_runner IS BOUND THEN
        NEW zcl_adcoset_parl_search_query(
          task_runner = task_runner
          scope       = scope
          settings    = settings )
      ELSE
        NEW zcl_adcoset_search_query(
          scope           = scope
          settings        = settings-basic_settings
          custom_settings = settings-custom_settings
          matchers        = zcl_adcoset_matcher_factory=>create_matchers(
            settings-pattern_config ) ) ).
  ENDMETHOD.


ENDCLASS.
