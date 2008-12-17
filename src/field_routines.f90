!> \file
!> $Id$
!> \author Chris Bradley
!> \brief This module handles all field related routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is openCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!> This module handles all field related routines.
MODULE FIELD_ROUTINES

  USE BASE_ROUTINES
  USE BASIS_ROUTINES
  USE NODE_ROUTINES
  USE COMP_ENVIRONMENT
  USE COORDINATE_ROUTINES
  USE GENERATED_MESH_ROUTINES
  USE DISTRIBUTED_MATRIX_VECTOR
  USE DOMAIN_MAPPINGS
  USE KINDS
  USE INPUT_OUTPUT
  USE ISO_VARYING_STRING
  USE LISTS
  USE MATRIX_VECTOR
  USE MPI
  USE STRINGS
  USE TYPES

  IMPLICIT NONE

  PRIVATE

  !Module parameters

  !> \addtogroup FIELD_ROUTINES_DependentTypes FIELD_ROUTINES::DependentTypes
  !> \brief Depedent field parameter types
  !> \see FIELD_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_INDEPENDENT_TYPE=1 !<Independent field type \see FIELD_ROUTINES_DependentTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_DEPENDENT_TYPE=2 !<Dependent field type \see FIELD_ROUTINES_DependentTypes,FIELD_ROUTINES
  !>@}

  !> \addtogroup FIELD_ROUTINES_DimensionTypes FIELD_ROUTINES::DimensionTypes
  !> \brief Field dimension parameter types
  !> \see FIELD_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_SCALAR_DIMENSION_TYPE=1 !<Scalar field \see FIELD_ROUTINES_DimensionTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_VECTOR_DIMENSION_TYPE=2 !<Vector field \see FIELD_ROUTINES_DimensionTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_TENSOR_DIMENSION_TYPE=2 !<Tensor field \see FIELD_ROUTINES_DimensionTypes,FIELD_ROUTINES
  !>@}
  
  !> \addtogroup FIELD_ROUTINES_FieldTypes FIELD_ROUTINES::FieldTypes
  !> \brief Field type parameters
  !> \see FIELD_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_GEOMETRIC_TYPE=1 !<Geometric field \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_FIBRE_TYPE=2 !<Fibre field \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_GENERAL_TYPE=3 !<General field \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_MATERIAL_TYPE=4 !<Material field \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
  !>@}

  !> \addtogroup FIELD_ROUTINES_InterpolationTypes FIELD_ROUTINES::InterpolationTypes
  !> \brief Field interpolation parameters
  !> \see FIELD_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_CONSTANT_INTERPOLATION=1 !<Constant interpolation. One parameter for the field \see FIELD_ROUTINES_InterpolationTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_ELEMENT_BASED_INTERPOLATION=2 !<Element based interpolation. Parameters are different in each element \see FIELD_ROUTINES_InterpolationTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_NODE_BASED_INTERPOLATION=3 !<Node based interpolation. Parameters are nodal based and a basis function is used \see FIELD_ROUTINES_InterpolationTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_GRID_POINT_BASED_INTERPOLATION=4 !<Grid point based interpolation. Parameters are different at each grid point \see FIELD_ROUTINES_InterpolationTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_GAUSS_POINT_BASED_INTERPOLATION=5 !<Gauss point based interpolation. Parameters are different at each Gauss point \see FIELD_ROUTINES_InterpolationTypes,FIELD_ROUTINES
  !>@}

  !> \addtogroup FIELD_ROUTINES_VariableTypes FIELD_ROUTINES::VariableTypes
  !> \brief Field variable type parameters
  !> \see FIELD_ROUTINES
  !> \todo sort out variable access routines so that you are always accessing by variable type rather than variable number.
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_NUMBER_OF_VARIABLE_TYPES=4 !<Number of different field variable types possible \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_STANDARD_VARIABLE_TYPE=1 !<Standard variable type i.e., u \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_NORMAL_VARIABLE_TYPE=2 !<Normal derivative variable type i.e., du/dn \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_TIME_DERIV1_VARIABLE_TYPE=3 !<First time derivative variable type i.e., du/dt \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_TIME_DERIV2_VARIABLE_TYPE=4 !<Second type derivative variable type i.e., d^2u/dt^2 \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
  !>@}

  !> \addtogroup FIELD_ROUTINES_DofTypes FIELD_ROUTINES::DofTypes
  !> \brief Field dof type parameters
  !> \see FIELD_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_CONSTANT_DOF_TYPE=1 !<The dof is from a field variable component with constant interpolation \see FIELD_ROUTINES_DofTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_ELEMENT_DOF_TYPE=2 !<The dof is from a field variable component with element based interpolation \see FIELD_ROUTINES_DofTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_NODE_DOF_TYPE=3 !<The dof is from a field variable component with node based interpolation \see FIELD_ROUTINES_DofTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_POINT_DOF_TYPE=4 !<The dof is from a field variable component with point based interpolation \see FIELD_ROUTINES_DofTypes,FIELD_ROUTINES
  !>@}

  !> \addtogroup FIELD_ROUTINES_ParameterSetTypes FIELD_ROUTINES::ParameterSetTypes
  !> \brief Field parameter set type parameters \todo make program defined constants negative?
  !> \see FIELD_ROUTINES
  !>@{
  INTEGER(INTG), PARAMETER :: FIELD_NUMBER_OF_SET_TYPES=99 !<The maximum number of different parameter sets for a field \see FIELD_ROUTINES_ParameterSetTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_VALUES_SET_TYPE=1 !<The parameter set corresponding to the field values \see FIELD_ROUTINES_ParameterSetTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_BOUNDARY_CONDITIONS_SET_TYPE=2 !<The parameter set corresponding to the field boundary conditions \see FIELD_ROUTINES_ParameterSetTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_INITIAL_CONDITIONS_SET_TYPE=3 !<The parameter set corresponding to the field initial conditions \see FIELD_ROUTINES_ParameterSetTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_ANALYTIC_SET_TYPE=4 !<The parameter set corresponding to the field values \see FIELD_ROUTINES_ParameterSetTypes,FIELD_ROUTINES
  !>@}
  
  !> \addtogroup FIELD_ROUTINES_ScalingTypes FIELD_ROUTINES::ScalingTypes
  !> \brief Field scaling type parameters
  !> \see FIELD_ROUTINES
  !>@{ 
  INTEGER(INTG), PARAMETER :: FIELD_NO_SCALING=0 !<The field is not scaled \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_UNIT_SCALING=1 !<The field has unit scaling \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_ARC_LENGTH_SCALING=2 !<The field has arc length scaling \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_ARITHMETIC_MEAN_SCALING=3 !<The field has arithmetic mean of the arc length scaling \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
  INTEGER(INTG), PARAMETER :: FIELD_HARMONIC_MEAN_SCALING=4 !<The field has geometric mean of the arc length scaling \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
  !>@}
  
  !Module types

  !Module variables

  !Interfaces

  INTERFACE FIELD_COMPONENT_INTERPOLATION_SET
    MODULE PROCEDURE FIELD_COMPONENT_INTERPOLATION_SET_NUMBER
    MODULE PROCEDURE FIELD_COMPONENT_INTERPOLATION_SET_PTR
  END INTERFACE !FIELD_COMPONENT_INTERPOLATION_SET
  
  INTERFACE FIELD_COMPONENT_MESH_COMPONENT_SET
    MODULE PROCEDURE FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER
    MODULE PROCEDURE FIELD_COMPONENT_MESH_COMPONENT_SET_PTR
  END INTERFACE !FIELD_COMPONENT_MESH_COMPONENT_SET
  
  INTERFACE FIELD_DEPENDENT_TYPE_SET
    MODULE PROCEDURE FIELD_DEPENDENT_TYPE_SET_NUMBER
    MODULE PROCEDURE FIELD_DEPENDENT_TYPE_SET_PTR
  END INTERFACE !FIELD_DEPENDENT_TYPE_SET
  
  INTERFACE FIELD_DIMENSION_SET
    MODULE PROCEDURE FIELD_DIMENSION_SET_NUMBER
    MODULE PROCEDURE FIELD_DIMENSION_SET_PTR
  END INTERFACE !FIELD_DIMENSION_SET
  
  INTERFACE FIELD_GEOMETRIC_FIELD_SET
    MODULE PROCEDURE FIELD_GEOMETRIC_FIELD_SET_NUMBER
    MODULE PROCEDURE FIELD_GEOMETRIC_FIELD_SET_PTR
  END INTERFACE !FIELD_GEOMETRIC_FIELD_SET
  
  INTERFACE FIELD_MESH_DECOMPOSITION_SET
    MODULE PROCEDURE FIELD_MESH_DECOMPOSITION_SET_NUMBER
    MODULE PROCEDURE FIELD_MESH_DECOMPOSITION_SET_PTR
  END INTERFACE !FIELD_MESH_DECOMPOSITION_SET
  
  INTERFACE FIELD_NUMBER_OF_COMPONENTS_SET
    MODULE PROCEDURE FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER
    MODULE PROCEDURE FIELD_NUMBER_OF_COMPONENTS_SET_PTR
  END INTERFACE !FIELD_NUMBER_OF_COMPONENTS_SET
 
  INTERFACE FIELD_NUMBER_OF_VARIABLES_SET
    MODULE PROCEDURE FIELD_NUMBER_OF_VARIABLES_SET_NUMBER
    MODULE PROCEDURE FIELD_NUMBER_OF_VARIABLES_SET_PTR
  END INTERFACE !FIELD_NUMBER_OF_VARIABLES_SET
 
  INTERFACE FIELD_SCALING_TYPE_SET
    MODULE PROCEDURE FIELD_SCALING_TYPE_SET_NUMBER
    MODULE PROCEDURE FIELD_SCALING_TYPE_SET_PTR
  END INTERFACE !FIELD_SCALING_TYPE_SET
 
  INTERFACE FIELD_TYPE_SET
    MODULE PROCEDURE FIELD_TYPE_SET_NUMBER
    MODULE PROCEDURE FIELD_TYPE_SET_PTR
  END INTERFACE !FIELD_TYPE_SET

  PUBLIC FIELD_INDEPENDENT_TYPE,FIELD_DEPENDENT_TYPE

  PUBLIC FIELD_SCALAR_DIMENSION_TYPE,FIELD_VECTOR_DIMENSION_TYPE

  PUBLIC FIELD_GEOMETRIC_TYPE,FIELD_FIBRE_TYPE,FIELD_GENERAL_TYPE,FIELD_MATERIAL_TYPE

  PUBLIC FIELD_CONSTANT_INTERPOLATION,FIELD_ELEMENT_BASED_INTERPOLATION,FIELD_NODE_BASED_INTERPOLATION, &
    & FIELD_GRID_POINT_BASED_INTERPOLATION,FIELD_GAUSS_POINT_BASED_INTERPOLATION

  PUBLIC FIELD_CONSTANT_DOF_TYPE,FIELD_ELEMENT_DOF_TYPE,FIELD_NODE_DOF_TYPE,FIELD_POINT_DOF_TYPE
  
  PUBLIC FIELD_NUMBER_OF_VARIABLE_TYPES,FIELD_STANDARD_VARIABLE_TYPE,FIELD_NORMAL_VARIABLE_TYPE,FIELD_TIME_DERIV1_VARIABLE_TYPE, &
    & FIELD_TIME_DERIV2_VARIABLE_TYPE

  PUBLIC FIELD_VALUES_SET_TYPE,FIELD_BOUNDARY_CONDITIONS_SET_TYPE,FIELD_INITIAL_CONDITIONS_SET_TYPE,FIELD_ANALYTIC_SET_TYPE

  PUBLIC FIELD_NO_SCALING,FIELD_UNIT_SCALING,FIELD_ARC_LENGTH_SCALING,FIELD_HARMONIC_MEAN_SCALING, FIELD_ARITHMETIC_MEAN_SCALING
  
  PUBLIC FIELD_COMPONENT_MESH_COMPONENT_GET,FIELD_COMPONENT_INTERPOLATION_GET,FIELD_DEPENDENT_TYPE_GET, &
    & FIELD_GEOMETRIC_FIELD_GET,FIELD_MESH_DECOMPOSITION_GET,FIELD_NUMBER_OF_COMPONENTS_GET,FIELD_NUMBER_OF_VARIABLES_GET,  &
    & FIELD_SCALING_TYPE_GET,FIELD_TYPE_GET 
     
  PUBLIC FIELD_CREATE_FINISH, &
    & FIELD_CREATE_START, &
    & FIELD_DESTROY,FIELDS_FINALISE, &
    & FIELDS_INITIALISE, &
    & FIELD_COMPONENT_MESH_COMPONENT_SET, &
    & FIELD_COMPONENT_INTERPOLATION_SET, &
    & FIELD_DEPENDENT_TYPE_SET, &
    & FIELD_GEOMETRIC_FIELD_SET, &
    & FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH, &
    & FIELD_INTERPOLATED_POINT_METRICS_CALCULATE, &
    & FIELD_INTERPOLATE_GAUSS,FIELD_INTERPOLATE_XI, &
    & FIELD_INTERPOLATED_POINT_METRICS_FINALISE, &
    & FIELD_INTERPOLATED_POINT_METRICS_INITIALISE, &
    & FIELD_INTERPOLATED_POINT_FINALISE, &
    & FIELD_INTERPOLATED_POINT_INITIALISE, & 
    & FIELD_INTERPOLATION_PARAMETERS_FINALISE, &
    & FIELD_INTERPOLATION_PARAMETERS_INITIALISE, &
    & FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET, &
    & FIELD_INTERPOLATION_PARAMETERS_LINE_GET, &
    & FIELD_MESH_DECOMPOSITION_SET, &
    & FIELD_NEXT_NUMBER_FIND, &
    & FIELD_NUMBER_OF_COMPONENTS_SET, &
    & FIELD_NUMBER_OF_VARIABLES_SET,  &
    & FIELD_PARAMETER_SET_ADD, &
    & FIELD_PARAMETER_SET_COPY, &
    & FIELD_PARAMETER_SET_CREATE, &
    & FIELD_PARAMETER_SET_GET, &
    & FIELD_PARAMETER_SET_RESTORE, &
    & FIELD_PARAMETER_SET_UPDATE_FINISH, &
    & FIELD_PARAMETER_SET_UPDATE_START, &
    & FIELD_PARAMETER_SET_UPDATE_CONSTANT, &
    & FIELD_PARAMETER_SET_UPDATE_DOF, &
    & FIELD_PARAMETER_SET_UPDATE_ELEMENT, &
    & FIELD_PARAMETER_SET_UPDATE_NODE, &
    & FIELD_SCALING_TYPE_SET,FIELD_TYPE_SET

CONTAINS

  !
  !================================================================================================================================
  !

!!MERGE: Check finished. Make into a subroutine. Don't get from a create values cache
  
  !>Gets the interpolation type for a field variable component identified by a pointer.
  FUNCTION FIELD_COMPONENT_INTERPOLATION_GET(FIELD,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the interpolation for
    INTEGER(INTG), INTENT(IN) :: FIELD_VARIABLE_NUMBER !<The field variable number of the field variable component to set
    INTEGER(INTG), INTENT(IN) :: FIELD_COMPONENT_NUMBER !<The field component number of the field variable component to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_COMPONENT_INTERPOLATION_GET !<The interpolation type to get \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_COMPONENT_INTERPOLATION_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD_VARIABLE_NUMBER>=1.AND.FIELD_VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
        IF(FIELD_COMPONENT_NUMBER>=1.AND.FIELD_COMPONENT_NUMBER<=FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS) THEN
          FIELD_COMPONENT_INTERPOLATION_GET=FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(FIELD_COMPONENT_NUMBER,FIELD_VARIABLE_NUMBER)
        ELSE
          LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(FIELD_COMPONENT_NUMBER,"*",ERR,ERROR))// &
            & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
            & " components"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
          & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
          & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_COMPONENT_INTERPOLATION_GET")
    RETURN
999 CALL ERRORS("FIELD_COMPONENT_INTERPOLATION_GET",ERR,ERROR)
    CALL EXITS("FIELD_COMPONENT_INTERPOLATION_GET")
    RETURN
  END FUNCTION FIELD_COMPONENT_INTERPOLATION_GET
  
  !
  !================================================================================================================================
  !

  !> Sets/changes the interpolation type for a field variable component identified by a user number and component number on a region.
  SUBROUTINE FIELD_COMPONENT_INTERPOLATION_SET_NUMBER(USER_NUMBER,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,REGION, &
    & INTERPOLATION_TYPE,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !>The user number of the field to change
    INTEGER(INTG), INTENT(IN) :: FIELD_VARIABLE_NUMBER !<The field variable number of the field variable component
    INTEGER(INTG), INTENT(IN) :: FIELD_COMPONENT_NUMBER !<The field component number of the field variable component
    TYPE(REGION_TYPE), POINTER :: REGION !<The region containing the field
    INTEGER(INTG), INTENT(IN) :: INTERPOLATION_TYPE !<The interpolation type to set/change \see FIELD_ROUTINES_InterpolationTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_COMPONENT_INTERPOLATION_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_COMPONENT_INTERPOLATION_SET_PTR(FIELD,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,INTERPOLATION_TYPE, &
      & ERR,ERROR,*999)
       
    CALL EXITS("FIELD_COMPONENT_INTERPOLATION_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_COMPONENT_INTERPOLATION_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_COMPONENT_INTERPOLATION_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_COMPONENT_INTERPOLATION_SET_NUMBER

  !
  !================================================================================================================================
  !

  !>Sets/changes the interpolation type for a field variable component identified by a pointer.
  SUBROUTINE FIELD_COMPONENT_INTERPOLATION_SET_PTR(FIELD,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,INTERPOLATION_TYPE, &
    & ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the interpolation for
    INTEGER(INTG), INTENT(IN) :: FIELD_VARIABLE_NUMBER !<The field variable number of the field variable component to set
    INTEGER(INTG), INTENT(IN) :: FIELD_COMPONENT_NUMBER !<The field component number of the field variable component to set
    INTEGER(INTG), INTENT(IN) :: INTERPOLATION_TYPE !<The interpolation type to set \see FIELD_ROUTINES_VariableTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_COMPONENT_INTERPOLATION_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(FIELD_VARIABLE_NUMBER>=1.AND.FIELD_VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
          IF(FIELD_COMPONENT_NUMBER>=1.AND.FIELD_COMPONENT_NUMBER<=FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS) THEN
            SELECT CASE(INTERPOLATION_TYPE)
            CASE(FIELD_CONSTANT_INTERPOLATION,FIELD_ELEMENT_BASED_INTERPOLATION,FIELD_NODE_BASED_INTERPOLATION, &
              & FIELD_GRID_POINT_BASED_INTERPOLATION,FIELD_GAUSS_POINT_BASED_INTERPOLATION)
              FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(FIELD_COMPONENT_NUMBER,FIELD_VARIABLE_NUMBER)=INTERPOLATION_TYPE
            CASE DEFAULT
              LOCAL_ERROR="Interpolation type "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_TYPE,"*",ERR,ERROR))// &
                & " is invalid"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
          ELSE
            LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(FIELD_COMPONENT_NUMBER,"*",ERR,ERROR))// &
              & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
              & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
              & " components"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_COMPONENT_INTERPOLATION_SET_PTR")
    RETURN
999 CALL ERRORS("FIELD_COMPONENT_INTERPOLATION_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_COMPONENT_INTERPOLATION_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_COMPONENT_INTERPOLATION_SET_PTR

  !
  !================================================================================================================================
  !

!!MERGE: Check finished. Make into a subroutine. Don't get from a create values cache  

  !>Gets the mesh component number for a field variable component identified by a pointer to a field and a field variable number.
  FUNCTION FIELD_COMPONENT_MESH_COMPONENT_GET(FIELD,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the mesh component for
    INTEGER(INTG), INTENT(IN) :: FIELD_VARIABLE_NUMBER !<The field variable number to set the field variable component for
    INTEGER(INTG), INTENT(IN) :: FIELD_COMPONENT_NUMBER !<The field component number to set the field variable component for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_COMPONENT_MESH_COMPONENT_GET !<The mesh component to set for the specified field variable component
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_COMPONENT_MESH_COMPONENT_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD_VARIABLE_NUMBER>=1.AND.FIELD_VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
        IF(FIELD_COMPONENT_NUMBER>=1.AND.FIELD_COMPONENT_NUMBER<=FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS) THEN
          FIELD_COMPONENT_MESH_COMPONENT_GET=FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(FIELD_COMPONENT_NUMBER,FIELD_VARIABLE_NUMBER)
        ELSE
          LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(FIELD_COMPONENT_NUMBER,"*",ERR,ERROR))// &
            & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
            & " components"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
          & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
          & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_COMPONENT_MESH_COMPONENT_GET")
    RETURN
999 CALL ERRORS("FIELD_COMPONENT_MESH_COMPONENT_GET",ERR,ERROR)
    CALL EXITS("FIELD_COMPONENT_MESH_COMPONENT_GET")
    RETURN
  END FUNCTION FIELD_COMPONENT_MESH_COMPONENT_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the mesh component number for a field variable component identified by a user number, component number and variable number on a region. \todo change variable number to variable type.
  SUBROUTINE FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER(USER_NUMBER,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,REGION, &
    & MESH_COMPONENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field to set the mesh component for
    INTEGER(INTG), INTENT(IN) :: FIELD_VARIABLE_NUMBER !<The field variable number of the field variable component to set
    INTEGER(INTG), INTENT(IN) :: FIELD_COMPONENT_NUMBER !<The field component number of the field variable component to set
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    INTEGER(INTG), INTENT(IN) :: MESH_COMPONENT_NUMBER !<The mesh component number to set for the specified field variable component
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_COMPONENT_MESH_COMPONENT_SET_PTR(FIELD,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,MESH_COMPONENT_NUMBER, &
      & ERR,ERROR,*999)
       
    CALL EXITS("FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_COMPONENT_MESH_COMPONENT_SET_NUMBER

  !
  !================================================================================================================================
  !

  !>Sets/changes the mesh component number for a field variable component identified by a pointer to a field and a field variable number.
  SUBROUTINE FIELD_COMPONENT_MESH_COMPONENT_SET_PTR(FIELD,FIELD_VARIABLE_NUMBER,FIELD_COMPONENT_NUMBER,MESH_COMPONENT_NUMBER, &
    & ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the mesh component for
    INTEGER(INTG), INTENT(IN) :: FIELD_VARIABLE_NUMBER !<The field variable number to set the field variable component for
    INTEGER(INTG), INTENT(IN) :: FIELD_COMPONENT_NUMBER !<The field component number to set the field variable component for
    INTEGER(INTG), INTENT(IN) :: MESH_COMPONENT_NUMBER !<The mesh component to set for the specified field variable component
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_COMPONENT_MESH_COMPONENT_SET_PTR",ERR,ERROR,*999)
   
    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(ASSOCIATED(FIELD%DECOMPOSITION)) THEN
          IF(ASSOCIATED(FIELD%DECOMPOSITION%MESH)) THEN
            IF(FIELD_VARIABLE_NUMBER>=1.AND.FIELD_VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
              IF(FIELD_COMPONENT_NUMBER>=1.AND.FIELD_COMPONENT_NUMBER<=FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS) THEN
                SELECT CASE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(FIELD_COMPONENT_NUMBER,FIELD_VARIABLE_NUMBER))
                CASE(FIELD_CONSTANT_INTERPOLATION)
                  LOCAL_ERROR="Field component number "//TRIM(NUMBER_TO_VSTRING(FIELD_COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " has constant field interpolation and so a mesh component cannot be specified"
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                CASE(FIELD_ELEMENT_BASED_INTERPOLATION,FIELD_NODE_BASED_INTERPOLATION,FIELD_GRID_POINT_BASED_INTERPOLATION, &
                  & FIELD_GAUSS_POINT_BASED_INTERPOLATION)
                  IF(MESH_COMPONENT_NUMBER>0.AND.MESH_COMPONENT_NUMBER<=FIELD%DECOMPOSITION%MESH%NUMBER_OF_COMPONENTS) THEN
                    FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(FIELD_COMPONENT_NUMBER,FIELD_VARIABLE_NUMBER)= &
                      & MESH_COMPONENT_NUMBER
                  ELSE
                    LOCAL_ERROR="Mesh component number "//TRIM(NUMBER_TO_VSTRING(MESH_COMPONENT_NUMBER,"*",ERR,ERROR))// &
                      & " is invalid. The component number must be between 1 and "// &
                      & TRIM(NUMBER_TO_VSTRING(FIELD%DECOMPOSITION%MESH%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
                      & " for mesh number "//TRIM(NUMBER_TO_VSTRING(FIELD%DECOMPOSITION%MESH%USER_NUMBER,"*",ERR,ERROR))
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  ENDIF
                CASE DEFAULT
                  LOCAL_ERROR="Interpolation type "//TRIM(NUMBER_TO_VSTRING(FIELD%CREATE_VALUES_CACHE% &
                    & INTERPOLATION_TYPE(FIELD_COMPONENT_NUMBER,FIELD_VARIABLE_NUMBER),"*",ERR,ERROR))// &
                    & " is invalid for field component number "//TRIM(NUMBER_TO_VSTRING(FIELD_COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
              ELSE
                LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(FIELD_COMPONENT_NUMBER,"*",ERR,ERROR))// &
                  & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
                  & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                  & TRIM(NUMBER_TO_VSTRING(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
                  & " components"
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(FIELD_VARIABLE_NUMBER,"*",ERR,ERROR))// &
                & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
              & " does not have a decomposition mesh associated"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
            & " does not have a decomposition associated"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_COMPONENT_MESH_COMPONENT_SET_PTR")
    RETURN
999 CALL ERRORS("FIELD_COMPONENT_MESH_COMPONENT_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_COMPONENT_MESH_COMPONENT_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_COMPONENT_MESH_COMPONENT_SET_PTR
  
  !
  !================================================================================================================================
  !

  !>Finalises a field variable component and deallocates all memory.
  SUBROUTINE FIELD_VARIABLE_COMPONENT_FINALISE(FIELD_VARIABLE_COMPONENT,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_VARIABLE_COMPONENT_TYPE) :: FIELD_VARIABLE_COMPONENT !<The field variable component to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_VARIABLE_COMPONENT_FINALISE",ERR,ERROR,*999)

    CALL FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE(FIELD_VARIABLE_COMPONENT,ERR,ERROR,*999)
    
    CALL EXITS("FIELD_VARIABLE_COMPONENT_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_COMPONENT_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_COMPONENT_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_COMPONENT_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises a field variable component.
  SUBROUTINE FIELD_VARIABLE_COMPONENT_INITIALISE(FIELD,VARIABLE_NUMBER,COMPONENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field containing the field variable component to initialise
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The field variable number of the field variable component
    INTEGER(INTG), INTENT(IN) :: COMPONENT_NUMBER !<The field component number of the field variable component
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: ne
    TYPE(BASIS_TYPE), POINTER :: BASIS
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_VARIABLE_COMPONENT_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
        IF(VARIABLE_NUMBER>=1.AND.VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
          IF(ALLOCATED(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS)) THEN
            IF(COMPONENT_NUMBER>=1.AND.COMPONENT_NUMBER<=FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS) THEN
              FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%COMPONENT_NUMBER=COMPONENT_NUMBER
              FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%FIELD_VARIABLE=>FIELD%VARIABLES(VARIABLE_NUMBER)
              FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%FIELD=>FIELD
              FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%REGION=>FIELD%REGION
              FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%INTERPOLATION_TYPE= &
                FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(COMPONENT_NUMBER,VARIABLE_NUMBER)
              SELECT CASE(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%INTERPOLATION_TYPE)
              CASE(FIELD_CONSTANT_INTERPOLATION)
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%MESH_COMPONENT_NUMBER=0
                NULLIFY(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%DOMAIN)
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS=1
              CASE(FIELD_ELEMENT_BASED_INTERPOLATION)
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%MESH_COMPONENT_NUMBER= &
                  FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(COMPONENT_NUMBER,VARIABLE_NUMBER)
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%DOMAIN=> &
                  & FIELD%DECOMPOSITION%DOMAIN(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                  & MESH_COMPONENT_NUMBER)%PTR
                DOMAIN=>FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%DOMAIN
                IF(.NOT.ASSOCIATED(DOMAIN)) THEN
                  LOCAL_ERROR="Field component "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " does not have a domain associated"
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS=1
              CASE(FIELD_NODE_BASED_INTERPOLATION)
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%MESH_COMPONENT_NUMBER= &
                  FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(COMPONENT_NUMBER,VARIABLE_NUMBER)
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%DOMAIN=> &
                  & FIELD%DECOMPOSITION%DOMAIN(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                  & MESH_COMPONENT_NUMBER)%PTR
                DOMAIN=>FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%DOMAIN
                IF(.NOT.ASSOCIATED(DOMAIN)) THEN
                  LOCAL_ERROR="Field component "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " does not have a domain associated"
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
                FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS=-1
                DO ne=1,DOMAIN%TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS
                  BASIS=>DOMAIN%TOPOLOGY%ELEMENTS%ELEMENTS(ne)%BASIS
                  IF(BASIS%NUMBER_OF_ELEMENT_PARAMETERS>FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                    & MAX_NUMBER_OF_INTERPOLATION_PARAMETERS) FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                    & MAX_NUMBER_OF_INTERPOLATION_PARAMETERS=BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                ENDDO !ne
              CASE(FIELD_GRID_POINT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE(FIELD_GAUSS_POINT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="An interpolation type of "//TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)% &
                  & COMPONENTS(COMPONENT_NUMBER)%INTERPOLATION_TYPE,"*",ERR,ERROR))// &
                  & " is invalid for component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                  & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                  & " for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
              END SELECT
              CALL FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE(FIELD%VARIABLES(VARIABLE_NUMBER)% &
                & COMPONENTS(COMPONENT_NUMBER),ERR,ERROR,*999)
            ELSE
              LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))//" components"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Field variable components have not been allocated",ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field create values cache is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_VARIABLE_COMPONENT_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_COMPONENT_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_COMPONENT_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_COMPONENT_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finalises a field variable component parameter to dof map and deallocates all memory.
  SUBROUTINE FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE(FIELD_VARIABLE_COMPONENT,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_VARIABLE_COMPONENT_TYPE) :: FIELD_VARIABLE_COMPONENT !<The field variable component to finialise the parameter to dof map for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE",ERR,ERROR,*999)

    IF(ALLOCATED(FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%ELEMENT_PARAM2DOF_MAP))  &
      & DEALLOCATE(FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%ELEMENT_PARAM2DOF_MAP)
    IF(ALLOCATED(FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP))  &
      & DEALLOCATE(FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP)
    IF(ALLOCATED(FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%POINT_PARAM2DOF_MAP))  &
      & DEALLOCATE(FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%POINT_PARAM2DOF_MAP)
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_CONSTANT_PARAMETERS=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_ELEMENT_PARAMETERS=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_NODE_PARAMETERS=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%MAX_NUMBER_OF_DERIVATIVES=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_POINT_PARAMETERS=0
    
    CALL EXITS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises a field variable component parameter to dof map.
  SUBROUTINE FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE(FIELD_VARIABLE_COMPONENT,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_VARIABLE_COMPONENT_TYPE) :: FIELD_VARIABLE_COMPONENT !<The field variable component to initialise the parameter to dof map for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE",ERR,ERROR,*999)

    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_CONSTANT_PARAMETERS=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_ELEMENT_PARAMETERS=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_NODE_PARAMETERS=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%MAX_NUMBER_OF_DERIVATIVES=0
    FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_POINT_PARAMETERS=0
    
    CALL EXITS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_COMPONENT_PARAM_TO_DOF_MAP_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finalises the field variable components for a field variable and deallocates all memory.
  SUBROUTINE FIELD_VARIABLE_COMPONENTS_FINALISE(FIELD_VARIABLE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_VARIABLE_TYPE) :: FIELD_VARIABLE !<The field variable to finalise the field variable components for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx

    CALL ENTERS("FIELD_VARIABLE_COMPONENTS_FINALISE",ERR,ERROR,*999)

    IF(ALLOCATED(FIELD_VARIABLE%COMPONENTS)) THEN
      DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
        CALL FIELD_VARIABLE_COMPONENT_FINALISE(FIELD_VARIABLE%COMPONENTS(component_idx),ERR,ERROR,*999)
      ENDDO !component_idx
      DEALLOCATE(FIELD_VARIABLE%COMPONENTS)
    ENDIF
    FIELD_VARIABLE%NUMBER_OF_COMPONENTS=0
       
    CALL EXITS("FIELD_VARIABLE_COMPONENTS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_COMPONENTS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_COMPONENTS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_COMPONENTS_FINALISE
  
  !
  !================================================================================================================================
  !

  !>Initialises the field components.
  SUBROUTINE FIELD_VARIABLE_COMPONENTS_INITIALISE(FIELD,VARIABLE_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the field variable components for
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The field variable number to initialise the field variable components for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FIELD_VARIABLE_COMPONENTS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
        IF(VARIABLE_NUMBER>=1.AND.VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
          IF(ALLOCATED(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS)) THEN
            CALL FLAG_ERROR("Field variable already has allocated components",ERR,ERROR,*999)
          ELSE
            ALLOCATE(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable components",ERR,ERROR,*999)
            DO component_idx=1,FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS
              CALL FIELD_VARIABLE_COMPONENT_INITIALISE(FIELD,VARIABLE_NUMBER,component_idx,ERR,ERROR,*999)
            ENDDO !component_idx
          ENDIF
        ELSE
          LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field create values cache is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_VARIABLE_COMPONENTS_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_COMPONENTS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_COMPONENTS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_COMPONENTS_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finishes the creation of a field on a region. 
  SUBROUTINE FIELD_CREATE_FINISH(REGION,FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finish the creation of
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_CREATE_FINISH",ERR,ERROR,*999)
    
    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%FIELDS)) THEN
        IF(ASSOCIATED(FIELD)) THEN
          IF(FIELD%FIELDS%REGION%USER_NUMBER==REGION%USER_NUMBER) THEN
            !Check field has a decomposition associated
            IF(ASSOCIATED(FIELD%DECOMPOSITION)) THEN
              !Initialise the components
              CALL FIELD_VARIABLES_INITIALISE(FIELD,ERR,ERROR,*999)
              IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD)) THEN
                CALL FIELD_CREATE_VALUES_CACHE_FINALISE(FIELD,ERR,ERROR,*999)
                FIELD%FIELD_FINISHED=.TRUE.
                !Calculate dof mappings
                CALL FIELD_MAPPINGS_INITIALISE(FIELD,ERR,ERROR,*999)
                CALL FIELD_MAPPINGS_CALCULATE(FIELD,ERR,ERROR,*999)
                !Initialise the field parameter sets and create a field values set
                CALL FIELD_PARAMETER_SETS_INITIALISE(FIELD,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_CREATE(FIELD,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                !Initialise the scalings
                CALL FIELD_SCALINGS_INITIALISE(FIELD,ERR,ERROR,*999)
                !Set up the geometric parameters 
                CALL FIELD_GEOMETRIC_PARAMETERS_INITIALISE(FIELD,ERR,ERROR,*999)
              ELSE
                CALL FLAG_ERROR("Field does not have a geometric field associated",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Field does not have a mesh decomposition associated",ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The specified field was created on region number "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD%FIELDS%REGION%USER_NUMBER,"*",ERR,ERROR))// &
              & " which is different from the specified region number of "// &
              & TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The fields on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))// &
          & " are not associated"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated",ERR,ERROR,*999)
    ENDIF

    IF(DIAGNOSTICS1) THEN
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"Region = ",REGION%USER_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Number of fields = ",REGION%FIELDS%NUMBER_OF_FIELDS,ERR,ERROR,*999)
      DO field_idx=1,REGION%FIELDS%NUMBER_OF_FIELDS
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Field number = ",field_idx,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Global number       = ", &
          & REGION%FIELDS%FIELDS(field_idx)%PTR%GLOBAL_NUMBER,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    User number         = ", &
          & REGION%FIELDS%FIELDS(field_idx)%PTR%USER_NUMBER,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Dependent type      = ", &
          & REGION%FIELDS%FIELDS(field_idx)%PTR%DEPENDENT_TYPE,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Field dimension     = ", &
          & REGION%FIELDS%FIELDS(field_idx)%PTR%DIMENSION,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Field type          = ", &
          & REGION%FIELDS%FIELDS(field_idx)%PTR%TYPE,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Number of variables = ", &
          & REGION%FIELDS%FIELDS(field_idx)%PTR%NUMBER_OF_VARIABLES,ERR,ERROR,*999)        
      ENDDO !field_idx    
    ENDIF
    
    CALL EXITS("FIELD_CREATE_FINISH")
    RETURN
999 CALL ERRORS("FIELD_CREATE_FINISH",ERR,ERROR)
    CALL EXITS("FIELD_CREATE_FINISH")
    RETURN 1
  END SUBROUTINE FIELD_CREATE_FINISH
  
  !
  !================================================================================================================================
  !

  !>Starts the creation of a field defined by a user number in the specified region. \todo Add in FIELD_INITIALISE
  SUBROUTINE FIELD_CREATE_START(USER_NUMBER,REGION,FIELD,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number for the field
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region in which to create the field
    TYPE(FIELD_TYPE), POINTER :: FIELD !<On return a pointer to the field being created
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_no,variable_type_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(FIELD_TYPE), POINTER :: NEW_FIELD
    TYPE(FIELD_PTR_TYPE), POINTER :: NEW_FIELDS(:)

    NULLIFY(NEW_FIELD)
    NULLIFY(NEW_FIELDS)

    CALL ENTERS("FIELD_CREATE_START",ERR,ERROR,*999)

    NULLIFY(FIELD)
    
    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%FIELDS)) THEN
        CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
        IF(ASSOCIATED(FIELD)) THEN
          LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(USER_NUMBER,"*",ERR,ERROR))// &
            & " has already been created on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*998)
        ELSE
          ALLOCATE(NEW_FIELD,STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new field",ERR,ERROR,*999)
          !Set default field properties
          NEW_FIELD%GLOBAL_NUMBER=REGION%FIELDS%NUMBER_OF_FIELDS+1
          NEW_FIELD%USER_NUMBER=USER_NUMBER
          NEW_FIELD%FIELD_FINISHED=.FALSE.
          NEW_FIELD%DEPENDENT_TYPE=FIELD_INDEPENDENT_TYPE
          NEW_FIELD%DIMENSION=FIELD_VECTOR_DIMENSION_TYPE
          NEW_FIELD%TYPE=FIELD_GEOMETRIC_TYPE
          NEW_FIELD%FIELDS=>REGION%FIELDS
          NEW_FIELD%REGION=>REGION
          NEW_FIELD%GEOMETRIC_FIELD=>NEW_FIELD
          NEW_FIELD%NUMBER_OF_VARIABLES=1
          NULLIFY(NEW_FIELD%DECOMPOSITION)
          NULLIFY(NEW_FIELD%CREATE_VALUES_CACHE)
          NULLIFY(NEW_FIELD%GEOMETRIC_FIELD_PARAMETERS)
          ALLOCATE(NEW_FIELD%VARIABLE_TYPE_MAP(FIELD_NUMBER_OF_VARIABLE_TYPES),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable type map",ERR,ERROR,*999)
          DO variable_type_idx=1,FIELD_NUMBER_OF_VARIABLE_TYPES
            NULLIFY(NEW_FIELD%VARIABLE_TYPE_MAP(variable_type_idx)%PTR)
          ENDDO !variable_type_idx
          NEW_FIELD%SCALINGS%SCALING_TYPE=FIELD_ARITHMETIC_MEAN_SCALING
          NEW_FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES=0
          NULLIFY(NEW_FIELD%MAPPINGS%DOMAIN_MAPPING)
          CALL FIELD_CREATE_VALUES_CACHE_INITIALISE(NEW_FIELD,ERR,ERROR,*999)
          !Add new field into list of fields in the region
          ALLOCATE(NEW_FIELDS(REGION%FIELDS%NUMBER_OF_FIELDS+1),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new fields",ERR,ERROR,*999)
          DO field_no=1,REGION%FIELDS%NUMBER_OF_FIELDS
            NEW_FIELDS(field_no)%PTR=>REGION%FIELDS%FIELDS(field_no)%PTR
          ENDDO !field_no
          NEW_FIELDS(REGION%FIELDS%NUMBER_OF_FIELDS+1)%PTR=>NEW_FIELD
          IF(ASSOCIATED(REGION%FIELDS%FIELDS)) DEALLOCATE(REGION%FIELDS%FIELDS)
          REGION%FIELDS%FIELDS=>NEW_FIELDS
          REGION%FIELDS%NUMBER_OF_FIELDS=REGION%FIELDS%NUMBER_OF_FIELDS+1
          FIELD=>NEW_FIELD
        ENDIF
      ELSE
        LOCAL_ERROR="The fields on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))// &
          & " are not associated"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated",ERR,ERROR,*998)
    ENDIF
    
    CALL EXITS("FIELD_CREATE_START")
    RETURN
999 IF(ASSOCIATED(NEW_FIELD)) DEALLOCATE(NEW_FIELD)
    IF(ASSOCIATED(NEW_FIELDS)) DEALLOCATE(NEW_FIELDS)
998 NULLIFY(FIELD)
    CALL ERRORS("FIELD_CREATE_START",ERR,ERROR)
    CALL EXITS("FIELD_CREATE_START")
    RETURN 1
  END SUBROUTINE FIELD_CREATE_START
  
  !
  !================================================================================================================================
  !

  !>Finalise the create values cache for a field.
  SUBROUTINE FIELD_CREATE_VALUES_CACHE_FINALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finialise the create values cache for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_CREATE_VALUES_CACHE_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
        IF(ALLOCATED(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES)) DEALLOCATE(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES)
        IF(ALLOCATED(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE)) DEALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE)
        IF(ALLOCATED(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER)) DEALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER)
        DEALLOCATE(FIELD%CREATE_VALUES_CACHE)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FIELD_CREATE_VALUES_CACHE_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_CREATE_VALUES_CACHE_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_CREATE_VALUES_CACHE_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_CREATE_VALUES_CACHE_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the create values cache for a field.
  SUBROUTINE FIELD_CREATE_VALUES_CACHE_INITIALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the create values cache for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: NUMBER_OF_COMPONENTS,component_idx,variable_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_CREATE_VALUES_CACHE_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
        CALL FLAG_ERROR("Create values cache is already associated",ERR,ERROR,*999)
      ELSE
        ALLOCATE(FIELD%CREATE_VALUES_CACHE,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate create values cache",ERR,ERROR,*999)
        SELECT CASE(FIELD%TYPE)
        CASE(FIELD_GEOMETRIC_TYPE,FIELD_FIBRE_TYPE)
          NUMBER_OF_COMPONENTS=FIELD%REGION%COORDINATE_SYSTEM%NUMBER_OF_DIMENSIONS
        CASE(FIELD_GENERAL_TYPE,FIELD_MATERIAL_TYPE)
          NUMBER_OF_COMPONENTS=1
        CASE DEFAULT
          LOCAL_ERROR="The field type of "//TRIM(NUMBER_TO_VSTRING(FIELD%TYPE,"*",ERR,ERROR))//" is invalid for field number "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
        END SELECT
        ALLOCATE(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocated create values cache variable types",ERR,ERROR,*999)
        ALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocated create values cache interpolation type",ERR,ERROR,*999)
        ALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocated create values cache mesh component type",ERR,ERROR,*999)
        FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS=NUMBER_OF_COMPONENTS
        DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
          FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(variable_idx)=variable_idx
          DO component_idx=1,NUMBER_OF_COMPONENTS
            FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(component_idx,variable_idx)=FIELD_NODE_BASED_INTERPOLATION
            FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(component_idx,variable_idx)=1
          ENDDO !component_idx
        ENDDO !variable_idx
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FIELD_CREATE_VALUES_CACHE_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_CREATE_VALUES_CACHE_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_CREATE_VALUES_CACHE_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_CREATE_VALUES_CACHE_INITIALISE
  
  !
  !================================================================================================================================
  !

!!MERGE: Check finished. Make into a subroutine.

  !>Gets the dependent type for a field indentified by a pointer.
  FUNCTION FIELD_DEPENDENT_TYPE_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set/change the dependent type for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_DEPENDENT_TYPE_GET !<The dependent type to get/change \see FIELD_ROUTINES_DependentTypes,FIELD_ROUTINES
    !Local Variables

    CALL ENTERS("FIELD_DEPENDENT_TYPE_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_DEPENDENT_TYPE_GET=FIELD%DEPENDENT_TYPE
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_DEPENDENT_TYPE_GET")
    RETURN
999 CALL ERRORS("FIELD_DEPENDENT_TYPE_GET",ERR,ERROR)
    CALL EXITS("FIELD_DEPENDENT_TYPE_GET")
    RETURN 
  END FUNCTION FIELD_DEPENDENT_TYPE_GET

  !
  !================================================================================================================================
  !

  !>Sets/changes the dependent type for a field identified by a user number.
  SUBROUTINE FIELD_DEPENDENT_TYPE_SET_NUMBER(USER_NUMBER,REGION,DEPENDENT_TYPE,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field to set the dependent type for
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    INTEGER(INTG), INTENT(IN) :: DEPENDENT_TYPE !<The dependent type to set/change for the field \see FIELD_ROUTINES_DependentTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_DEPENDENT_TYPE_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_DEPENDENT_TYPE_SET_PTR(FIELD,DEPENDENT_TYPE,ERR,ERROR,*999)
    
    CALL EXITS("FIELD_DEPENDENT_TYPE_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_DEPENDENT_TYPE_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_DEPENDENT_TYPE_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_DEPENDENT_TYPE_SET_NUMBER
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the dependent type for a field indentified by a pointer.
  SUBROUTINE FIELD_DEPENDENT_TYPE_SET_PTR(FIELD,DEPENDENT_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set/change the dependent type for
    INTEGER(INTG), INTENT(IN) :: DEPENDENT_TYPE !<The dependent type to set/change \see FIELD_ROUTINES_DependentTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: OLD_VARIABLE_TYPES
    INTEGER(INTG), ALLOCATABLE :: OLD_INTERPOLATION_TYPE(:,:),OLD_MESH_COMPONENT_NUMBER(:,:)
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_DEPENDENT_TYPE_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
          SELECT CASE(DEPENDENT_TYPE)
          CASE(FIELD_INDEPENDENT_TYPE)
            IF(FIELD%NUMBER_OF_VARIABLES/=1) THEN
              ALLOCATE(OLD_INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old interpolation type",ERR,ERROR,*999)
              ALLOCATE(OLD_MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES), &
                & STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old mesh component number",ERR,ERROR,*999)
              OLD_VARIABLE_TYPES=FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(1)
              OLD_INTERPOLATION_TYPE=FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE
              OLD_MESH_COMPONENT_NUMBER=FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER
              DEALLOCATE(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES)
              DEALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE)
              DEALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER)
              ALLOCATE(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(1),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate variable types",ERR,ERROR,*999)
              ALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,1),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolation type",ERR,ERROR,*999)
              ALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,1),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate mesh component number",ERR,ERROR,*999)
              FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(1)=OLD_VARIABLE_TYPES
              FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(:,1)=OLD_INTERPOLATION_TYPE(:,1)
              FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(:,1)=OLD_MESH_COMPONENT_NUMBER(:,1)
              DEALLOCATE(OLD_INTERPOLATION_TYPE)
              DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
              FIELD%NUMBER_OF_VARIABLES=1
            ENDIF
            FIELD%DEPENDENT_TYPE=FIELD_INDEPENDENT_TYPE
          CASE(FIELD_DEPENDENT_TYPE)
            FIELD%DEPENDENT_TYPE=FIELD_DEPENDENT_TYPE
          CASE DEFAULT
            LOCAL_ERROR="The supplied dependent type of "//TRIM(NUMBER_TO_VSTRING(DEPENDENT_TYPE,"*",ERR,ERROR))//" is invalid"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Field create values cache is not associated",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_DEPENDENT_TYPE_SET_PTR")
    RETURN
999 IF(ALLOCATED(OLD_INTERPOLATION_TYPE)) DEALLOCATE(OLD_INTERPOLATION_TYPE)
    IF(ALLOCATED(OLD_MESH_COMPONENT_NUMBER)) DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
    CALL ERRORS("FIELD_DEPENDENT_TYPE_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_DEPENDENT_TYPE_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_DEPENDENT_TYPE_SET_PTR
  
  !
  !================================================================================================================================
  !

  !>Destroys a field identified by a pointer to a field.
  SUBROUTINE FIELD_DESTROY(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx,field_position,field_position2
    TYPE(FIELD_TYPE), POINTER :: FIELD2,GEOMETRIC_FIELD
    TYPE(FIELD_PTR_TYPE), POINTER :: NEW_FIELDS(:),NEW_FIELDS_USING(:)
    TYPE(REGION_TYPE), POINTER :: REGION

    NULLIFY(NEW_FIELDS)
    NULLIFY(NEW_FIELDS_USING)

    CALL ENTERS("FIELD_DESTROY",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      REGION=>FIELD%REGION
      IF(ASSOCIATED(REGION)) THEN
        field_position=FIELD%GLOBAL_NUMBER
        GEOMETRIC_FIELD=>FIELD%GEOMETRIC_FIELD
        IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN
          IF(ASSOCIATED(GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS)) THEN
            !Delete this field from the list of fields using the geometric field.
            field_position2=0
            DO field_idx=1,GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING
              FIELD2=>GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(field_idx)%PTR
              IF(FIELD2%USER_NUMBER==FIELD%USER_NUMBER) THEN
                field_position2=field_idx
                EXIT
              ENDIF
            ENDDO !field_idx
            IF(field_position2/=0) THEN
              ALLOCATE(NEW_FIELDS_USING(GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING+1),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new fields using",ERR,ERROR,*999)
              DO field_idx=1,GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING
                IF(field_idx<field_position2) THEN
                  NEW_FIELDS_USING(field_idx)%PTR=>GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(field_idx)%PTR
                ELSE IF(field_idx>field_position2) THEN
                  NEW_FIELDS_USING(field_idx-1)%PTR=>GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(field_idx)%PTR
                ENDIF
              ENDDO !field_idx
              GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING=GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS% &
                & NUMBER_OF_FIELDS_USING-1
              IF(ASSOCIATED(GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING)) &
                & DEALLOCATE(GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING)
              GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING=>NEW_FIELDS_USING
            ELSE
              !??? Error
            ENDIF
          ENDIF
        ENDIF
!!TODO: move to field finalise
        CALL FIELD_SCALINGS_FINALISE(FIELD,ERR,ERROR,*999)
        CALL FIELD_VARIABLES_FINALISE(FIELD,ERR,ERROR,*999)
        CALL FIELD_CREATE_VALUES_CACHE_FINALISE(FIELD,ERR,ERROR,*999)
        CALL FIELD_GEOMETRIC_PARAMETERS_FINALISE(FIELD,ERR,ERROR,*999)
        CALL FIELD_MAPPINGS_FINALISE(FIELD,ERR,ERROR,*999)
        IF(ALLOCATED(FIELD%VARIABLE_TYPE_MAP)) DEALLOCATE(FIELD%VARIABLE_TYPE_MAP)
        DEALLOCATE(FIELD)
        IF(REGION%FIELDS%NUMBER_OF_FIELDS>1) THEN
          ALLOCATE(NEW_FIELDS(REGION%FIELDS%NUMBER_OF_FIELDS-1),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new fields",ERR,ERROR,*999)
          DO field_idx=1,REGION%FIELDS%NUMBER_OF_FIELDS
            IF(field_idx<field_position) THEN
              NEW_FIELDS(field_idx)%PTR=>REGION%FIELDS%FIELDS(field_idx)%PTR
            ELSE IF(field_idx>field_position) THEN
              REGION%FIELDS%FIELDS(field_idx)%PTR%GLOBAL_NUMBER=REGION%FIELDS%FIELDS(field_idx)%PTR%GLOBAL_NUMBER-1
              NEW_FIELDS(field_idx-1)%PTR=>REGION%FIELDS%FIELDS(field_idx)%PTR
            ENDIF
          ENDDO !field_no
          DEALLOCATE(REGION%FIELDS%FIELDS)
          REGION%FIELDS%FIELDS=>NEW_FIELDS
          REGION%FIELDS%NUMBER_OF_FIELDS=REGION%FIELDS%NUMBER_OF_FIELDS-1
        ELSE
          DEALLOCATE(REGION%FIELDS%FIELDS)
          REGION%FIELDS%NUMBER_OF_FIELDS=0
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field region is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_DESTROY")
    RETURN
999 IF(ASSOCIATED(NEW_FIELDS)) DEALLOCATE(NEW_FIELDS)
    IF(ASSOCIATED(NEW_FIELDS_USING)) DEALLOCATE(NEW_FIELDS_USING)
    CALL ERRORS("FIELD_DESTROY",ERR,ERROR)
    CALL EXITS("FIELD_DESTROY")
    RETURN 1
  END SUBROUTINE FIELD_DESTROY

  !
  !================================================================================================================================
  !

!!MERGE: Check finished. Make into a subroutine.

  !>Gets the field dimension for a field identified by a pointer.
  FUNCTION FIELD_DIMENSION_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set/change the dimension for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_DIMENSION_GET !<The field dimension to get \see FIELD_ROUTINES_DimensionTypes,FIELD_ROUTINES
    !Local Variables

    CALL ENTERS("FIELD_DIMENSION_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_DIMENSION_GET=FIELD%DIMENSION
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_DIMENSION_GET")
    RETURN
999 CALL ERRORS("FIELD_DIMENSION_GET",ERR,ERROR)
    CALL EXITS("FIELD_DIMENSION_GET")
    RETURN 
  END FUNCTION FIELD_DIMENSION_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the field dimension for a field identified by a user number.
  SUBROUTINE FIELD_DIMENSION_SET_NUMBER(USER_NUMBER,REGION,FIELD_DIMENSION,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field to set the dimension for
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    INTEGER(INTG), INTENT(IN) :: FIELD_DIMENSION !<The dimension to set/change \see FIELD_ROUTINES_DimensionTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_DIMENSION_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_DIMENSION_SET_PTR(FIELD,FIELD_DIMENSION,ERR,ERROR,*999)
       
    CALL EXITS("FIELD_DIMENSION_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_DIMENSION_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_DIMENSION_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_DIMENSION_SET_NUMBER

  !
  !================================================================================================================================
  !

  !>Sets/changes the field dimension for a field identified by a pointer.
  SUBROUTINE FIELD_DIMENSION_SET_PTR(FIELD,FIELD_DIMENSION,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set/change the dimension for
    INTEGER(INTG), INTENT(IN) :: FIELD_DIMENSION !<The field dimension to set/change \see FIELD_ROUTINES_DimensionTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx
    INTEGER(INTG), ALLOCATABLE :: OLD_INTERPOLATION_TYPE(:,:),OLD_MESH_COMPONENT_NUMBER(:,:)
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_DIMENSION_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
          SELECT CASE(FIELD_DIMENSION)
          CASE(FIELD_SCALAR_DIMENSION_TYPE)
            IF(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS/=1) THEN
              ALLOCATE(OLD_INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old interpolation type",ERR,ERROR,*999)
              ALLOCATE(OLD_MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES), &
                & STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old mesh component number",ERR,ERROR,*999)
              OLD_INTERPOLATION_TYPE=FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE
              OLD_MESH_COMPONENT_NUMBER=FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER
              DEALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE)
              DEALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER)
              ALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(1,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolation type",ERR,ERROR,*999)
              ALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(1,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate mesh component number",ERR,ERROR,*999)
              DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
                FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(1,variable_idx)=OLD_INTERPOLATION_TYPE(1,variable_idx)
                FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(1,variable_idx)=OLD_MESH_COMPONENT_NUMBER(1,variable_idx)
              ENDDO !variable_idx
              DEALLOCATE(OLD_INTERPOLATION_TYPE)
              DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
              FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS=1
            ENDIF
            FIELD%DIMENSION=FIELD_SCALAR_DIMENSION_TYPE
          CASE(FIELD_VECTOR_DIMENSION_TYPE)
            FIELD%DIMENSION=FIELD_VECTOR_DIMENSION_TYPE
          CASE DEFAULT
            LOCAL_ERROR="Field dimension "//TRIM(NUMBER_TO_VSTRING(FIELD_DIMENSION,"*",ERR,ERROR))//" is not valid"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Field create values cache is not associated",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_DIMENSION_SET_PTR")
    RETURN
999 IF(ALLOCATED(OLD_INTERPOLATION_TYPE)) DEALLOCATE(OLD_INTERPOLATION_TYPE)
    IF(ALLOCATED(OLD_MESH_COMPONENT_NUMBER)) DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
    CALL ERRORS("FIELD_DIMENSION_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_DIMENSION_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_DIMENSION_SET_PTR
  
  !
  !================================================================================================================================
  !

  !>Interpolates a field at a gauss point to give an interpolated point. PARTIAL_DERIVATIVE_TYPE controls which partial derivatives are evaluated. If it is NO_PART_DERIV then only the field values are interpolated. If it is FIRST_PART_DERIV then the field values and first partial derivatives are interpolated. If it is SECOND_PART_DERIV the the field values and first and second partial derivatives are evaluated. Old CMISS name XEXG, ZEXG
  SUBROUTINE FIELD_INTERPOLATE_GAUSS(PARTIAL_DERIVATIVE_TYPE,QUADRATURE_SCHEME,GAUSS_POINT_NUMBER,INTERPOLATED_POINT,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: PARTIAL_DERIVATIVE_TYPE !<The partial derivative type of the provided field interpolation
    INTEGER(INTG), INTENT(IN) :: QUADRATURE_SCHEME !<The quadrature scheme of the Gauss points \see BASIS_ROUTINES_QuadratureSchemes,BASIS_ROUTINES
    INTEGER(INTG), INTENT(IN) :: GAUSS_POINT_NUMBER !<The number of the Gauss point to interpolate the field at
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT !<The pointer to the interpolated point which will contain the field interpolation information at the specified Gauss point
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,ni,nu
    TYPE(COORDINATE_SYSTEM_TYPE), POINTER :: COORDINATE_SYSTEM
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_INTERPOLATE_GAUSS",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATED_POINT)) THEN
      INTERPOLATION_PARAMETERS=>INTERPOLATED_POINT%INTERPOLATION_PARAMETERS
      IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
        COORDINATE_SYSTEM=>INTERPOLATION_PARAMETERS%FIELD%REGION%COORDINATE_SYSTEM
        SELECT CASE(PARTIAL_DERIVATIVE_TYPE)
        CASE(NO_PART_DERIV)
          INTERPOLATED_POINT%PARTIAL_DERIVATIVE_TYPE=NO_PART_DERIV
          DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
            INTERPOLATED_POINT%VALUES(component_idx,1)=BASIS_INTERPOLATE_GAUSS(INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR, &
              & NO_PART_DERIV,QUADRATURE_SCHEME,GAUSS_POINT_NUMBER,INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),ERR,ERROR)
            IF(ERR/=0) GOTO 999
            CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,NO_PART_DERIV,INTERPOLATED_POINT%VALUES(component_idx,1), &
              & ERR,ERROR,*999)
          ENDDO! component_idx
        CASE(FIRST_PART_DERIV)
          INTERPOLATED_POINT%PARTIAL_DERIVATIVE_TYPE=FIRST_PART_DERIV
          DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
            !Handle the first case of no partial derivative
            INTERPOLATED_POINT%VALUES(component_idx,1)=BASIS_INTERPOLATE_GAUSS(INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR, &
              & NO_PART_DERIV,QUADRATURE_SCHEME,GAUSS_POINT_NUMBER,INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),ERR,ERROR)
            IF(ERR/=0) GOTO 999
            CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,NO_PART_DERIV,INTERPOLATED_POINT%VALUES(component_idx,1), &
              & ERR,ERROR,*999)
            !Now process all the first partial derivatives
            DO ni=1,INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR%NUMBER_OF_XI
              nu=PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni)
              INTERPOLATED_POINT%VALUES(component_idx,nu)=BASIS_INTERPOLATE_GAUSS(INTERPOLATION_PARAMETERS% &
                & BASES(component_idx)%PTR,nu,QUADRATURE_SCHEME,GAUSS_POINT_NUMBER, &
                & INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),ERR,ERROR)
              IF(ERR/=0) GOTO 999
              CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,nu,INTERPOLATED_POINT%VALUES(component_idx,nu),ERR,ERROR,*999)
            ENDDO !ni
          ENDDO! component_idx
        CASE(SECOND_PART_DERIV)
          DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
            DO nu=1,INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR%NUMBER_OF_PARTIAL_DERIVATIVES
              INTERPOLATED_POINT%VALUES(component_idx,nu)=BASIS_INTERPOLATE_GAUSS(INTERPOLATION_PARAMETERS% &
                & BASES(component_idx)%PTR,nu,QUADRATURE_SCHEME,GAUSS_POINT_NUMBER, &
                & INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),ERR,ERROR)
              IF(ERR/=0) GOTO 999
              CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,nu,INTERPOLATED_POINT%VALUES(component_idx,nu),ERR,ERROR,*999)
            ENDDO! nu
          ENDDO! component_idx
          INTERPOLATED_POINT%PARTIAL_DERIVATIVE_TYPE=SECOND_PART_DERIV
        CASE DEFAULT
          LOCAL_ERROR="The partial derivative type of "//TRIM(NUMBER_TO_VSTRING(PARTIAL_DERIVATIVE_TYPE,"*",ERR,ERROR))// &
            & " is invalid"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Interpolated point interpolation parameters is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolated point is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATE_GAUSS")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATE_GAUSS",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATE_GAUSS")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATE_GAUSS
    
  !
  !================================================================================================================================
  !

  !>Interpolates a field at a xi location to give an interpolated point. XI is the element location to be interpolated at. PARTIAL_DERIVATIVE_TYPE controls which partial derivatives are evaluated. If it is NO_PART_DERIV then only the field values are interpolated. If it is FIRST_PART_DERIV then the field values and first partial derivatives are interpolated. If it is SECOND_PART_DERIV the the field values and first and second partial derivatives are evaluated. Old CMISS name PXI
  SUBROUTINE FIELD_INTERPOLATE_XI(PARTIAL_DERIVATIVE_TYPE,XI,INTERPOLATED_POINT,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: PARTIAL_DERIVATIVE_TYPE !<The partial derivative type of the provide field interpolation
    REAL(DP), INTENT(IN) :: XI(:) !<XI(ni). The ni'th Xi coordinate to evaluate the field at
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT !<The pointer to the interpolated point which will contain the field interpolation information at the specified Xi point
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,ni,nu
    TYPE(COORDINATE_SYSTEM_TYPE), POINTER :: COORDINATE_SYSTEM
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_INTERPOLATE_XI",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATED_POINT)) THEN
      INTERPOLATION_PARAMETERS=>INTERPOLATED_POINT%INTERPOLATION_PARAMETERS
      IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
        !!TODO: Fix this check. You can have less Xi directions than the mesh number of dimensions e.g., interpolating a line
        !IF(SIZE(XI,1)>=INTERPOLATION_PARAMETERS%FIELD%DECOMPOSITION%MESH%NUMBER_OF_DIMENSIONS) THEN
          COORDINATE_SYSTEM=>INTERPOLATION_PARAMETERS%FIELD%REGION%COORDINATE_SYSTEM
          SELECT CASE(PARTIAL_DERIVATIVE_TYPE)
          CASE(NO_PART_DERIV)
            INTERPOLATED_POINT%PARTIAL_DERIVATIVE_TYPE=NO_PART_DERIV
            DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
              INTERPOLATED_POINT%VALUES(component_idx,1)=BASIS_INTERPOLATE_XI(INTERPOLATION_PARAMETERS% &
                & BASES(component_idx)%PTR,NO_PART_DERIV,XI,INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),ERR,ERROR)
              IF(ERR/=0) GOTO 999
              CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,NO_PART_DERIV,INTERPOLATED_POINT%VALUES(component_idx,1), &
                & ERR,ERROR,*999)
            ENDDO! component_idx
          CASE(FIRST_PART_DERIV)
            INTERPOLATED_POINT%PARTIAL_DERIVATIVE_TYPE=FIRST_PART_DERIV
            DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
              !Handle the first case of no partial derivative
              INTERPOLATED_POINT%VALUES(component_idx,1)=BASIS_INTERPOLATE_XI(INTERPOLATION_PARAMETERS% &
                & BASES(component_idx)%PTR,NO_PART_DERIV,XI,INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),ERR,ERROR)
              IF(ERR/=0) GOTO 999
              CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,NO_PART_DERIV,INTERPOLATED_POINT%VALUES(component_idx,1), &
                & ERR,ERROR,*999)
              !Now process all the first partial derivatives
              DO ni=1,INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR%NUMBER_OF_XI
                nu=PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni)
                INTERPOLATED_POINT%VALUES(component_idx,nu)=BASIS_INTERPOLATE_XI(INTERPOLATION_PARAMETERS% &
                  & BASES(component_idx)%PTR,nu,XI,INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx), &
                  & ERR,ERROR)
                IF(ERR/=0) GOTO 999
                CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,nu,INTERPOLATED_POINT%VALUES(component_idx,nu), &
                  & ERR,ERROR,*999)
              ENDDO !ni
            ENDDO! component_idx
          CASE(SECOND_PART_DERIV)
            DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
              DO nu=1,INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR%NUMBER_OF_PARTIAL_DERIVATIVES
                INTERPOLATED_POINT%VALUES(component_idx,nu)=BASIS_INTERPOLATE_XI(INTERPOLATION_PARAMETERS% &
                  & BASES(component_idx)%PTR,nu,XI,INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx), &
                  & ERR,ERROR)
                IF(ERR/=0) GOTO 999
                CALL COORDINATE_INTERPOLATION_ADJUST(COORDINATE_SYSTEM,nu,INTERPOLATED_POINT%VALUES(component_idx,nu), &
                  & ERR,ERROR,*999)
              ENDDO! nu
            ENDDO! component_idx
            INTERPOLATED_POINT%PARTIAL_DERIVATIVE_TYPE=SECOND_PART_DERIV
          CASE DEFAULT
            LOCAL_ERROR="The partial derivative type of "//TRIM(NUMBER_TO_VSTRING(PARTIAL_DERIVATIVE_TYPE,"*",ERR,ERROR))// &
              & " is invalid"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        !ELSE
        !  LOCAL_ERROR="Invalid number of Xi directions. The supplied Xi has "// &
        !    & TRIM(NUMBER_TO_VSTRING(SIZE(XI,1),"*",ERR,ERROR))//" directions and the required number of directions is "// &
        !    & TRIM(NUMBER_TO_VSTRING(INTERPOLATED_POINT%INTERPOLATION_PARAMETERS%FIELD%DECOMPOSITION%MESH%NUMBER_OF_DIMENSIONS, &
        !    & "*",ERR,ERROR))
        !  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        !ENDIF
      ELSE
        CALL FLAG_ERROR("Interpolated point interpolation parameters is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolated point is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATE_XI")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATE_XI",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATE_XI")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATE_XI
    
  !
  !================================================================================================================================
  !
  
  !>Finalises the interpolated point and deallocates all memory.
  SUBROUTINE FIELD_INTERPOLATED_POINT_FINALISE(INTERPOLATED_POINT,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT !<A pointer to the interpolated point to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_INTERPOLATED_POINT_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATED_POINT)) THEN
      IF(ALLOCATED(INTERPOLATED_POINT%VALUES)) DEALLOCATE(INTERPOLATED_POINT%VALUES)
      DEALLOCATE(INTERPOLATED_POINT)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATED_POINT_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATED_POINT_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATED_POINT_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATED_POINT_FINALISE
    
  !
  !================================================================================================================================
  !

  !>Initialises the interpolated point for an interpolation parameters
  SUBROUTINE FIELD_INTERPOLATED_POINT_INITIALISE(INTERPOLATION_PARAMETERS,INTERPOLATED_POINT,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS !<A pointer to the interpolation parameters to initialise the interpolated point for
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT !<On exit, A pointer to the interpolated point that has been initialised
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR,NUMBER_OF_DIMENSIONS
    TYPE(VARYING_STRING) :: DUMMY_ERROR

    CALL ENTERS("FIELD_INTERPOLATED_POINT_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
      IF(ASSOCIATED(INTERPOLATION_PARAMETERS%FIELD)) THEN
        IF(ASSOCIATED(INTERPOLATED_POINT)) THEN
          CALL FLAG_ERROR("Interpolated point is already associated",ERR,ERROR,*998)
        ELSE
          ALLOCATE(INTERPOLATED_POINT,STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point",ERR,ERROR,*999)
          INTERPOLATED_POINT%INTERPOLATION_PARAMETERS=>INTERPOLATION_PARAMETERS
          NUMBER_OF_DIMENSIONS=INTERPOLATION_PARAMETERS%FIELD%DECOMPOSITION%MESH%NUMBER_OF_DIMENSIONS
          INTERPOLATED_POINT%MAX_PARTIAL_DERIVATIVE_INDEX=PARTIAL_DERIVATIVE_MAXIMUM_MAP(NUMBER_OF_DIMENSIONS)
          ALLOCATE(INTERPOLATED_POINT%VALUES(INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS, &
            & INTERPOLATED_POINT%MAX_PARTIAL_DERIVATIVE_INDEX),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point values",ERR,ERROR,*999)
          INTERPOLATED_POINT%VALUES=0.0_DP
        ENDIF
      ELSE
        CALL FLAG_ERROR("Interpolation parameters field is not associated",ERR,ERROR,*998)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolation parameters is not associated",ERR,ERROR,*998)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATED_POINT_INITIALISE")
    RETURN
999 CALL FIELD_INTERPOLATED_POINT_FINALISE(INTERPOLATED_POINT,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("FIELD_INTERPOLATED_POINT_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATED_POINT_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATED_POINT_INITIALISE
    
  !
  !================================================================================================================================
  !

  !>Calculates the interpolated point metrics and the associated interpolated point
  SUBROUTINE FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(JACOBIAN_TYPE,INTERPOLATED_POINT_METRICS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_INTERPOLATED_POINT_METRICS_TYPE), POINTER :: INTERPOLATED_POINT_METRICS !<A pointer to the interpolated point metrics
    INTEGER(INTG), INTENT(IN) :: JACOBIAN_TYPE !<The Jacobian type of the calculation \see COORDINATE_ROUTINES_JacobianTypes,COORDINATE_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(COORDINATE_SYSTEM_TYPE), POINTER :: COORDINATE_SYSTEM
    TYPE(FIELD_TYPE), POINTER :: FIELD
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS
    
    CALL ENTERS("FIELD_INTERPOLATED_POINT_METRICS_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATED_POINT_METRICS)) THEN
      INTERPOLATED_POINT=>INTERPOLATED_POINT_METRICS%INTERPOLATED_POINT
      INTERPOLATION_PARAMETERS=>INTERPOLATED_POINT%INTERPOLATION_PARAMETERS
      FIELD=>INTERPOLATION_PARAMETERS%FIELD
      COORDINATE_SYSTEM=>FIELD%REGION%COORDINATE_SYSTEM
      IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE.OR.FIELD%TYPE==FIELD_FIBRE_TYPE) THEN
        CALL COORDINATE_METRICS_CALCULATE(COORDINATE_SYSTEM,JACOBIAN_TYPE,INTERPOLATED_POINT_METRICS,ERR,ERROR,*999)
      ELSE
        CALL FLAG_ERROR("The field is not a geometric or fibre field",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolated point metrics is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATED_POINT_METRICS_CALCULATE")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATED_POINT_METRICS_CALCULATE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATED_POINT_METRICS_CALCULATE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATED_POINT_METRICS_CALCULATE
        
  !
  !================================================================================================================================
  !

  !>Finalises the interpolated point metrics and deallocates all memory.
  SUBROUTINE FIELD_INTERPOLATED_POINT_METRICS_FINALISE(INTERPOLATED_POINT_METRICS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_INTERPOLATED_POINT_METRICS_TYPE), POINTER :: INTERPOLATED_POINT_METRICS !<A pointer to the interpolated point metrics to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_INTERPOLATED_POINT_METRICS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATED_POINT_METRICS)) THEN
      IF(ALLOCATED(INTERPOLATED_POINT_METRICS%GL)) DEALLOCATE(INTERPOLATED_POINT_METRICS%GL)
      IF(ALLOCATED(INTERPOLATED_POINT_METRICS%GU)) DEALLOCATE(INTERPOLATED_POINT_METRICS%GU)
      IF(ALLOCATED(INTERPOLATED_POINT_METRICS%DX_DXI)) DEALLOCATE(INTERPOLATED_POINT_METRICS%DX_DXI)
      IF(ALLOCATED(INTERPOLATED_POINT_METRICS%DXI_DX)) DEALLOCATE(INTERPOLATED_POINT_METRICS%DXI_DX)
      DEALLOCATE(INTERPOLATED_POINT_METRICS)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATED_POINT_METRICS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATED_POINT_METRICS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATED_POINT_METRICS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATED_POINT_METRICS_FINALISE
    
  !
  !================================================================================================================================
  !

  !>Initialises the interpolated point metrics for an interpolated point.
  SUBROUTINE FIELD_INTERPOLATED_POINT_METRICS_INITIALISE(INTERPOLATED_POINT,INTERPOLATED_POINT_METRICS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT !A pointer to the interpolated point to initliase the interpolated point metrics for
    TYPE(FIELD_INTERPOLATED_POINT_METRICS_TYPE), POINTER :: INTERPOLATED_POINT_METRICS !<On exit, a pointer to the interpolated point metrics that have been initialised
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: NUMBER_OF_XI_DIMENSIONS,NUMBER_OF_X_DIMENSIONS
    INTEGER(INTG) :: DUMMY_ERR
    TYPE(VARYING_STRING) :: DUMMY_ERROR,LOCAL_ERROR

    CALL ENTERS("FIELD_INTERPOLATED_POINT_METRICS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATED_POINT)) THEN
      IF(ASSOCIATED(INTERPOLATED_POINT_METRICS)) THEN
        CALL FLAG_ERROR("Interpolated point metrics is already associated",ERR,ERROR,*998)
      ELSE
        NUMBER_OF_X_DIMENSIONS=INTERPOLATED_POINT%INTERPOLATION_PARAMETERS%FIELD%REGION%COORDINATE_SYSTEM%NUMBER_OF_DIMENSIONS
        NUMBER_OF_XI_DIMENSIONS=INTERPOLATED_POINT%INTERPOLATION_PARAMETERS%FIELD%DECOMPOSITION%MESH%NUMBER_OF_DIMENSIONS
        IF(NUMBER_OF_X_DIMENSIONS==SIZE(INTERPOLATED_POINT%VALUES,1)) THEN
          ALLOCATE(INTERPOLATED_POINT_METRICS,STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point metrics",ERR,ERROR,*999)
          ALLOCATE(INTERPOLATED_POINT_METRICS%GL(NUMBER_OF_XI_DIMENSIONS,NUMBER_OF_XI_DIMENSIONS),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point metrics convariant tensor",ERR,ERROR,*999)
          ALLOCATE(INTERPOLATED_POINT_METRICS%GU(NUMBER_OF_XI_DIMENSIONS,NUMBER_OF_XI_DIMENSIONS),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point metrics contravariant tensor",ERR,ERROR,*999)
          ALLOCATE(INTERPOLATED_POINT_METRICS%DX_DXI(NUMBER_OF_X_DIMENSIONS,NUMBER_OF_XI_DIMENSIONS),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point metrics dX_dXi",ERR,ERROR,*999)        
          ALLOCATE(INTERPOLATED_POINT_METRICS%DXI_DX(NUMBER_OF_XI_DIMENSIONS,NUMBER_OF_X_DIMENSIONS),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolated point metrics dXi_dX",ERR,ERROR,*999)        
          INTERPOLATED_POINT_METRICS%INTERPOLATED_POINT=>INTERPOLATED_POINT
          INTERPOLATED_POINT_METRICS%NUMBER_OF_X_DIMENSIONS=NUMBER_OF_X_DIMENSIONS
          INTERPOLATED_POINT_METRICS%NUMBER_OF_XI_DIMENSIONS=NUMBER_OF_XI_DIMENSIONS
          INTERPOLATED_POINT_METRICS%GL=0.0_DP
          INTERPOLATED_POINT_METRICS%GU=0.0_DP
          INTERPOLATED_POINT_METRICS%DX_DXI=0.0_DP
          INTERPOLATED_POINT_METRICS%DXI_DX=0.0_DP
          INTERPOLATED_POINT_METRICS%JACOBIAN=0.0_DP
          INTERPOLATED_POINT_METRICS%JACOBIAN_TYPE=0
        ELSE
          LOCAL_ERROR="The number of coordinate dimensions ("//TRIM(NUMBER_TO_VSTRING(NUMBER_OF_X_DIMENSIONS,"*",ERR,ERROR))// &
            & ") does not match the number of components of the interpolated point ("// &
            & TRIM(NUMBER_TO_VSTRING(SIZE(INTERPOLATED_POINT%VALUES,1),"*",ERR,ERROR))//")"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*998)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolation point is not associated",ERR,ERROR,*998)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATED_POINT_METRICS_INITIALISE")
    RETURN
999 CALL FIELD_INTERPOLATED_POINT_METRICS_FINALISE(INTERPOLATED_POINT_METRICS,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("FIELD_INTERPOLATED_POINT_METRICS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATED_POINT_METRICS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATED_POINT_METRICS_INITIALISE
    
  !
  !================================================================================================================================
  !

  !>Gets the interpolation parameters for a particular element. Old CMISS name XPXE, ZPZE
  SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(PARAMETER_SET_NUMBER,ELEMENT_NUMBER,INTERPOLATION_PARAMETERS,ERR,ERROR,*)
    
    !Argument variables
    INTEGER(INTG), INTENT(IN) :: PARAMETER_SET_NUMBER !<The field parameter set number to get the element parameters for
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to get the element parameters for
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS !<A pointer to the interpolation parameters
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,mk,nk,nn,np,ns,ny,ny2,scaling_idx
    REAL(DP), POINTER :: FIELD_PARAMETER_SET_DATA(:),SCALE_FACTORS(:)
    TYPE(BASIS_TYPE), POINTER :: BASIS
    TYPE(COORDINATE_SYSTEM_TYPE), POINTER :: COORDINATE_SYSTEM
    TYPE(DOMAIN_ELEMENTS_TYPE), POINTER :: ELEMENTS_TOPOLOGY
    TYPE(DOMAIN_NODES_TYPE), POINTER :: NODES_TOPOLOGY
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
      IF(PARAMETER_SET_NUMBER>0.AND.PARAMETER_SET_NUMBER<=INTERPOLATION_PARAMETERS%FIELD%PARAMETER_SETS% &
        & NUMBER_OF_PARAMETER_SETS) THEN
        PARAMETER_SET=>INTERPOLATION_PARAMETERS%FIELD%PARAMETER_SETS%SET_TYPE(PARAMETER_SET_NUMBER)%PTR
        IF(ASSOCIATED(PARAMETER_SET)) THEN
          NULLIFY(FIELD_PARAMETER_SET_DATA)
          CALL DISTRIBUTED_VECTOR_DATA_GET(PARAMETER_SET%PARAMETERS,FIELD_PARAMETER_SET_DATA,ERR,ERROR,*999)
          IF(ELEMENT_NUMBER>0.AND.ELEMENT_NUMBER<=INTERPOLATION_PARAMETERS%FIELD%DECOMPOSITION%DOMAIN(1)%PTR% &
            & TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS) THEN
            COORDINATE_SYSTEM=>INTERPOLATION_PARAMETERS%FIELD%REGION%COORDINATE_SYSTEM
            DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
              SELECT CASE(INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%INTERPOLATION_TYPE)
              CASE(FIELD_CONSTANT_INTERPOLATION)
                ny=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                  & CONSTANT_PARAM2DOF_MAP(0)
                INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(component_idx)=1
                INTERPOLATION_PARAMETERS%PARAMETERS(1,component_idx)=FIELD_PARAMETER_SET_DATA(ny)
              CASE(FIELD_ELEMENT_BASED_INTERPOLATION)
                ny=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                  & ELEMENT_PARAM2DOF_MAP(ELEMENT_NUMBER,0)
                INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(component_idx)=1
                INTERPOLATION_PARAMETERS%PARAMETERS(1,component_idx)=FIELD_PARAMETER_SET_DATA(ny)
              CASE(FIELD_NODE_BASED_INTERPOLATION)
                ELEMENTS_TOPOLOGY=>INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN%TOPOLOGY%ELEMENTS
                NODES_TOPOLOGY=>INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN%TOPOLOGY%NODES
                BASIS=>ELEMENTS_TOPOLOGY%ELEMENTS(ELEMENT_NUMBER)%BASIS
                INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR=>BASIS
                INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(component_idx)=BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                SELECT CASE(INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALING_TYPE)
                CASE(FIELD_NO_SCALING) 
                  DO nn=1,BASIS%NUMBER_OF_NODES
                    np=ELEMENTS_TOPOLOGY%ELEMENTS(ELEMENT_NUMBER)%ELEMENT_NODES(nn)
                    DO mk=1,BASIS%NUMBER_OF_DERIVATIVES(nn)
                      nk=ELEMENTS_TOPOLOGY%ELEMENTS(ELEMENT_NUMBER)%ELEMENT_DERIVATIVES(mk,nn)
                      ns=BASIS%ELEMENT_PARAMETER_INDEX(mk,nn)
                      ny=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                        & NODE_PARAM2DOF_MAP(nk,np,0)
                      INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)
                    ENDDO !mk
                  ENDDO !nn
                CASE(FIELD_UNIT_SCALING,FIELD_ARITHMETIC_MEAN_SCALING,FIELD_HARMONIC_MEAN_SCALING)
                  scaling_idx=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%SCALING_INDEX
                  NULLIFY(SCALE_FACTORS)
                  CALL DISTRIBUTED_VECTOR_DATA_GET(INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALINGS(scaling_idx)% &
                    & SCALE_FACTORS,SCALE_FACTORS,ERR,ERROR,*999)
                  DO nn=1,BASIS%NUMBER_OF_NODES
                    np=ELEMENTS_TOPOLOGY%ELEMENTS(ELEMENT_NUMBER)%ELEMENT_NODES(nn)
                    DO mk=1,BASIS%NUMBER_OF_DERIVATIVES(nn)
                      nk=ELEMENTS_TOPOLOGY%ELEMENTS(ELEMENT_NUMBER)%ELEMENT_DERIVATIVES(mk,nn)
                      ns=BASIS%ELEMENT_PARAMETER_INDEX(nk,nn)
                      ny=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                        & NODE_PARAM2DOF_MAP(nk,np,0)
                      ny2=NODES_TOPOLOGY%NODES(np)%DOF_INDEX(nk)
                      !INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)* &
                      !  & INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALINGS(scaling_idx)%SCALE_FACTORS(ns,ELEMENT_NUMBER)
                      !INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)* &
                      !  & INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALINGS(scaling_idx)%SCALE_FACTORS(nk,np)
                      INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)*SCALE_FACTORS(ny2)
                    ENDDO !mk
                  ENDDO !nn
                CASE(FIELD_ARC_LENGTH_SCALING)
                  CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The scaling type of "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%SCALINGS% &
                    & SCALING_TYPE,"*",ERR,ERROR))//" is invalid for field number "// &
                    & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
                CALL COORDINATE_INTERPOLATION_PARAMETERS_ADJUST(COORDINATE_SYSTEM,INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
              CASE(FIELD_GRID_POINT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE(FIELD_GAUSS_POINT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The interpolation type of "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD_VARIABLE% &
                  & COMPONENTS(component_idx)%INTERPOLATION_TYPE,"*",ERR,ERROR))//" is invalid for component number "// &
                  & TRIM(NUMBER_TO_VSTRING(component_idx,"*",ERR,ERROR))//" of field number "// &
                  & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            ENDDO !component_idx
          ELSE
            LOCAL_ERROR="The element number of "//TRIM(NUMBER_TO_VSTRING(ELEMENT_NUMBER,"*",ERR,ERROR))// &
              & " is invalid. The number must be between 1 and "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD% &
              & DECOMPOSITION%DOMAIN(1)%PTR%TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS,"*",ERR,ERROR))//" for field number "// &
              & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field parameter set number of "//TRIM(NUMBER_TO_VSTRING(PARAMETER_SET_NUMBER,"*",ERR,ERROR))// &
            & " has not been created for field number "// &
            & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The field parameter set number of "//TRIM(NUMBER_TO_VSTRING(PARAMETER_SET_NUMBER,"*",ERR,ERROR))// &
          & " is invalid. The number must be between 1 and "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD% &
          & PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS,"*",ERR,ERROR))//" for field number "// &
          & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolation parameters is not associated",ERR,ERROR,*999)
    ENDIF

    IF(DIAGNOSTICS1) THEN
      CALL WRITE_STRING(DIAGNOSTIC_OUTPUT_TYPE,"Interpolation parameters:",ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Field number = ",INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Field variable number = ",INTERPOLATION_PARAMETERS%FIELD_VARIABLE% &
        & VARIABLE_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Parameter set number = ",PARAMETER_SET_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Element number = ",ELEMENT_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Number of components = ",INTERPOLATION_PARAMETERS%FIELD_VARIABLE% &
        & NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
      DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Component = ",component_idx,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"      Number of parameters = ",INTERPOLATION_PARAMETERS% &
          & NUMBER_OF_PARAMETERS(component_idx),ERR,ERROR,*999)
        CALL WRITE_STRING_VECTOR(DIAGNOSTIC_OUTPUT_TYPE,1,1,INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(component_idx),4,4, &
          & INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),'("      Parameters :",4(X,E13.6))','(18X,4(X,E13.6))', &
          & ERR,ERROR,*999)
      ENDDO !component_idx
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET
  
  !
  !================================================================================================================================
  !

  !>Finalises the interpolation parameters and deallocates all memory
  SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_FINALISE(INTERPOLATION_PARAMETERS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS !<A pointer to the interpolation parameters to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_INTERPOLATION_PARAMETERS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
      IF(ALLOCATED(INTERPOLATION_PARAMETERS%BASES)) DEALLOCATE(INTERPOLATION_PARAMETERS%BASES)
      IF(ALLOCATED(INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS)) DEALLOCATE(INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS)
      IF(ALLOCATED(INTERPOLATION_PARAMETERS%PARAMETERS)) DEALLOCATE(INTERPOLATION_PARAMETERS%PARAMETERS)
      DEALLOCATE(INTERPOLATION_PARAMETERS)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATION_PARAMETERS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_FINALISE
    
  !
  !================================================================================================================================
  !

  !>Initialises the interpolation parameters for a field variable.
  SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_INITIALISE(FIELD,VARIABLE_NUMBER,INTERPOLATION_PARAMETERS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the interpolation parameters for
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The field variable number to initialise the interpolation parameters for
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS !<On exit, a pointer to the initialised interpolation parameters.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,DUMMY_ERR
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(VARYING_STRING) :: DUMMY_ERROR,LOCAL_ERROR

    CALL ENTERS("FIELD_INTERPOLATION_PARAMETERS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(VARIABLE_NUMBER>0.AND.VARIABLE_NUMBER<=FIELD_NUMBER_OF_VARIABLE_TYPES) THEN
          FIELD_VARIABLE=>FIELD%VARIABLE_TYPE_MAP(VARIABLE_NUMBER)%PTR
          IF(ASSOCIATED(FIELD_VARIABLE)) THEN
            IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
              CALL FLAG_ERROR("Interpolation parameters is already associated",ERR,ERROR,*998)
            ELSE
              ALLOCATE(INTERPOLATION_PARAMETERS,STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolation parameters",ERR,ERROR,*999)
              INTERPOLATION_PARAMETERS%FIELD=>FIELD
              INTERPOLATION_PARAMETERS%FIELD_VARIABLE=>FIELD_VARIABLE
              ALLOCATE(INTERPOLATION_PARAMETERS%BASES(FIELD_VARIABLE%NUMBER_OF_COMPONENTS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate bases",ERR,ERROR,*999)
              ALLOCATE(INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(FIELD_VARIABLE%NUMBER_OF_COMPONENTS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolation type",ERR,ERROR,*999)
              ALLOCATE(INTERPOLATION_PARAMETERS%PARAMETERS(FIELD_VARIABLE%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS, &
                & FIELD_VARIABLE%NUMBER_OF_COMPONENTS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate parameters",ERR,ERROR,*999)
              DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                NULLIFY(INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR)
              ENDDO !component_idx
              INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS=0
              INTERPOLATION_PARAMETERS%PARAMETERS=0.0_DP
            ENDIF            
          ELSE
            LOCAL_ERROR="The field variable number of "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
              & " has not been created for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*998)
          ENDIF
        ELSE
          LOCAL_ERROR="The field variable number of "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " is invalid. The number must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_VARIABLE_TYPES,"*",ERR,ERROR))//" for field number "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*998)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field has not been finished",ERR,ERROR,*998)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*998)
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_INITIALISE")
    RETURN
999 CALL FIELD_INTERPOLATION_PARAMETERS_FINALISE(INTERPOLATION_PARAMETERS,DUMMY_ERR,DUMMY_ERROR,*998)
998 CALL ERRORS("FIELD_INTERPOLATION_PARAMETERS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_INITIALISE
    
  !
  !================================================================================================================================
  !

  !>Gets the interpolation parameters for a particular line. Old CMISS name XPXE, ZPZE
  SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_LINE_GET(PARAMETER_SET_NUMBER,LINE_NUMBER,INTERPOLATION_PARAMETERS,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: PARAMETER_SET_NUMBER !<The field parameter set number to get the line parameters for
    INTEGER(INTG), INTENT(IN) :: LINE_NUMBER !<The line number to get the line parameters for
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS !<A pointer to the interpolation parameters
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,mk,nk,nn,np,ns,ny,ny2,scaling_idx
    REAL(DP), POINTER :: FIELD_PARAMETER_SET_DATA(:),SCALE_FACTORS(:)
    TYPE(BASIS_TYPE), POINTER :: BASIS
    TYPE(COORDINATE_SYSTEM_TYPE), POINTER :: COORDINATE_SYSTEM
    TYPE(DOMAIN_LINES_TYPE), POINTER :: LINES_TOPOLOGY
    TYPE(DOMAIN_NODES_TYPE), POINTER :: NODES_TOPOLOGY
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_INTERPOLATION_PARAMETERS_LINE_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) THEN
      IF(PARAMETER_SET_NUMBER>0.AND.PARAMETER_SET_NUMBER<=INTERPOLATION_PARAMETERS%FIELD%PARAMETER_SETS% &
        & NUMBER_OF_PARAMETER_SETS) THEN
        PARAMETER_SET=>INTERPOLATION_PARAMETERS%FIELD%PARAMETER_SETS%SET_TYPE(PARAMETER_SET_NUMBER)%PTR
        IF(ASSOCIATED(PARAMETER_SET)) THEN
          NULLIFY(FIELD_PARAMETER_SET_DATA)
          CALL DISTRIBUTED_VECTOR_DATA_GET(PARAMETER_SET%PARAMETERS,FIELD_PARAMETER_SET_DATA,ERR,ERROR,*999)
          IF(LINE_NUMBER>0.AND.LINE_NUMBER<=INTERPOLATION_PARAMETERS%FIELD%DECOMPOSITION%DOMAIN(1)%PTR% &
            & TOPOLOGY%LINES%NUMBER_OF_LINES) THEN
            COORDINATE_SYSTEM=>INTERPOLATION_PARAMETERS%FIELD%REGION%COORDINATE_SYSTEM
            DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
              SELECT CASE(INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%INTERPOLATION_TYPE)
              CASE(FIELD_CONSTANT_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE(FIELD_ELEMENT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE(FIELD_NODE_BASED_INTERPOLATION)
                LINES_TOPOLOGY=>INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN%TOPOLOGY%LINES
                NODES_TOPOLOGY=>INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN%TOPOLOGY%NODES
                BASIS=>LINES_TOPOLOGY%LINES(LINE_NUMBER)%BASIS
                INTERPOLATION_PARAMETERS%BASES(component_idx)%PTR=>BASIS
                INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(component_idx)=BASIS%NUMBER_OF_ELEMENT_PARAMETERS
                SELECT CASE(INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALING_TYPE)
                CASE(FIELD_NO_SCALING) 
                  DO nn=1,BASIS%NUMBER_OF_NODES
                    np=LINES_TOPOLOGY%LINES(LINE_NUMBER)%NODES_IN_LINE(nn)
                    DO mk=1,BASIS%NUMBER_OF_DERIVATIVES(nn)
                      nk=LINES_TOPOLOGY%LINES(LINE_NUMBER)%DERIVATIVES_IN_LINE(mk,nn)
                      ns=BASIS%ELEMENT_PARAMETER_INDEX(mk,nn)
                      ny=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                        & NODE_PARAM2DOF_MAP(nk,np,0)
                      INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)
                    ENDDO !mk
                  ENDDO !nn
                CASE(FIELD_UNIT_SCALING,FIELD_ARITHMETIC_MEAN_SCALING,FIELD_HARMONIC_MEAN_SCALING)
                  scaling_idx=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%SCALING_INDEX
                  NULLIFY(SCALE_FACTORS)
                  CALL DISTRIBUTED_VECTOR_DATA_GET(INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALINGS(scaling_idx)% &
                    & SCALE_FACTORS,SCALE_FACTORS,ERR,ERROR,*999)
                  DO nn=1,BASIS%NUMBER_OF_NODES
                    np=LINES_TOPOLOGY%LINES(LINE_NUMBER)%NODES_IN_LINE(nn)
                    DO mk=1,BASIS%NUMBER_OF_DERIVATIVES(nn)
                      nk=LINES_TOPOLOGY%LINES(LINE_NUMBER)%DERIVATIVES_IN_LINE(mk,nn)
                      ns=BASIS%ELEMENT_PARAMETER_INDEX(mk,nn)
                      ny=INTERPOLATION_PARAMETERS%FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                        & NODE_PARAM2DOF_MAP(nk,np,0)
                      ny2=NODES_TOPOLOGY%NODES(np)%DOF_INDEX(nk)
                      !INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)* &
                      !  & INTERPOLATION_PARAMETERS%FIELD%SCALINGS%SCALINGS(scaling_idx)%SCALE_FACTORS(nk,np)
                      INTERPOLATION_PARAMETERS%PARAMETERS(ns,component_idx)=FIELD_PARAMETER_SET_DATA(ny)*SCALE_FACTORS(ny2)
                    ENDDO !mk
                  ENDDO !nn
                CASE(FIELD_ARC_LENGTH_SCALING)
                  CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The scaling type of "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%SCALINGS% &
                    & SCALING_TYPE,"*",ERR,ERROR))//" is invalid for field number "// &
                    & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
                CALL COORDINATE_INTERPOLATION_PARAMETERS_ADJUST(COORDINATE_SYSTEM,INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
              CASE(FIELD_GRID_POINT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE(FIELD_GAUSS_POINT_BASED_INTERPOLATION)
                CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The interpolation type of "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD_VARIABLE% &
                  & COMPONENTS(component_idx)%INTERPOLATION_TYPE,"*",ERR,ERROR))//" is invalid for component number "// &
                  & TRIM(NUMBER_TO_VSTRING(component_idx,"*",ERR,ERROR))//" of field number "// &
                  & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            ENDDO !component_idx
          ELSE
            LOCAL_ERROR="The line number of "//TRIM(NUMBER_TO_VSTRING(LINE_NUMBER,"*",ERR,ERROR))// &
              & " is invalid. The number must be between 1 and "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD% &
              & DECOMPOSITION%DOMAIN(1)%PTR%TOPOLOGY%LINES%NUMBER_OF_LINES,"*",ERR,ERROR))//" for field number "// &
              & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field parameter set number of "//TRIM(NUMBER_TO_VSTRING(PARAMETER_SET_NUMBER,"*",ERR,ERROR))// &
            & " has not been created for field number "// &
            & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The field parameter set number of "//TRIM(NUMBER_TO_VSTRING(PARAMETER_SET_NUMBER,"*",ERR,ERROR))// &
          & " is invalid. The number must be between 1 and "//TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD% &
          & PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS,"*",ERR,ERROR))//" for field number "// &
          & TRIM(NUMBER_TO_VSTRING(INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,"*",ERR,ERROR))
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Interpolation parameters is not associated",ERR,ERROR,*999)
    ENDIF

    IF(DIAGNOSTICS1) THEN
      CALL WRITE_STRING(DIAGNOSTIC_OUTPUT_TYPE,"Interpolation parameters:",ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Field number = ",INTERPOLATION_PARAMETERS%FIELD%USER_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Field variable number = ",INTERPOLATION_PARAMETERS%FIELD_VARIABLE% &
        & VARIABLE_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Parameter set number = ",PARAMETER_SET_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Line number = ",LINE_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Number of components = ",INTERPOLATION_PARAMETERS%FIELD_VARIABLE% &
        & NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
      DO component_idx=1,INTERPOLATION_PARAMETERS%FIELD_VARIABLE%NUMBER_OF_COMPONENTS
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Component = ",component_idx,ERR,ERROR,*999)
        CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"      Number of parameters = ",INTERPOLATION_PARAMETERS% &
          & NUMBER_OF_PARAMETERS(component_idx),ERR,ERROR,*999)
        CALL WRITE_STRING_VECTOR(DIAGNOSTIC_OUTPUT_TYPE,1,1,INTERPOLATION_PARAMETERS%NUMBER_OF_PARAMETERS(component_idx),4,4, &
          & INTERPOLATION_PARAMETERS%PARAMETERS(:,component_idx),'("      Parameters :",4(X,E13.6))','(18X,4(X,E13.6))', &
          & ERR,ERROR,*999)
      ENDDO !component_idx
    ENDIF
    
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_LINE_GET")
    RETURN
999 CALL ERRORS("FIELD_INTERPOLATION_PARAMETERS_LINE_GET",ERR,ERROR)
    CALL EXITS("FIELD_INTERPOLATION_PARAMETERS_LINE_GET")
    RETURN 1
  END SUBROUTINE FIELD_INTERPOLATION_PARAMETERS_LINE_GET
  
  !
  !================================================================================================================================
  !

  !>Finalises the mappings for a field and deallocates all memory. 
  SUBROUTINE FIELD_MAPPINGS_FINALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_MAPPINGS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      CALL FIELD_MAPPINGS_DOF_TO_PARAM_MAP_FINALISE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP,ERR,ERROR,*999)
      IF(ASSOCIATED(FIELD%MAPPINGS%DOMAIN_MAPPING)) THEN
        CALL DOMAIN_MAPPINGS_MAPPING_FINALISE(FIELD%MAPPINGS%DOMAIN_MAPPING,ERR,ERROR,*999)
        DEALLOCATE(FIELD%MAPPINGS%DOMAIN_MAPPING)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_MAPPINGS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_MAPPINGS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_MAPPINGS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_MAPPINGS_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the mappings for a field. 
  SUBROUTINE FIELD_MAPPINGS_INITIALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the mappings for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_MAPPINGS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      CALL FIELD_MAPPINGS_DOF_TO_PARAM_MAP_INITIALISE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP,ERR,ERROR,*999)
      IF(ASSOCIATED(FIELD%MAPPINGS%DOMAIN_MAPPING)) THEN
        CALL FLAG_ERROR("Field already has a domain mapping associated",ERR,ERROR,*999)
      ELSE
        ALLOCATE(FIELD%MAPPINGS%DOMAIN_MAPPING,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocated field domain mapping",ERR,ERROR,*999)
        CALL DOMAIN_MAPPINGS_MAPPING_INITIALISE(FIELD%MAPPINGS%DOMAIN_MAPPING,FIELD%DECOMPOSITION%NUMBER_OF_DOMAINS,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_MAPPINGS_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_MAPPINGS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_MAPPINGS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_MAPPINGS_INITIALISE

  !
  !================================================================================================================================
  !

  !>Calculates the mappings for a field.
  SUBROUTINE FIELD_MAPPINGS_CALCULATE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to calculate the mappings for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx,component_idx,GLOBAL_DOFS_OFFSET,VARIABLE_GLOBAL_DOFS_OFFSET,NUMBER_OF_GLOBAL_DOFS, &
      & NUMBER_OF_GLOBAL_VARIABLE_DOFS,NUMBER_OF_LOCAL_DOFS,NUMBER_OF_CONSTANT_DOFS,NUMBER_OF_ELEMENT_DOFS,NUMBER_OF_NODE_DOFS, &
      & NUMBER_OF_POINT_DOFS,NUMBER_OF_VARIABLE_DOFS,TOTAL_NUMBER_OF_LOCAL_DOFS,TOTAL_NUMBER_OF_VARIABLE_DOFS,NUMBER_OF_DOMAINS, &
      & mesh_component_idx,global_ny,variable_global_ny,local_ny,variable_local_ny,domain_idx,domain_no,constant_nyy,element_nyy, &
      & node_nyy,point_nyy,MAX_NUMBER_OF_DERIVATIVES,ne,nk,np,ny,NUMBER_OF_COMPUTATIONAL_NODES,my_computational_node_number
    INTEGER(INTG), ALLOCATABLE :: LOCAL_DOFS_OFFSETS(:),VARIABLE_LOCAL_DOFS_OFFSETS(:)
    TYPE(DECOMPOSITION_TYPE), POINTER :: DECOMPOSITION
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: ELEMENTS_MAPPING,DOFS_MAPPING,FIELD_DOFS_MAPPING,FIELD_VARIABLE_DOFS_MAPPING
    TYPE(DOMAIN_TOPOLOGY_TYPE), POINTER :: DOMAIN_TOPOLOGY
    TYPE(FIELD_VARIABLE_COMPONENT_TYPE), POINTER :: FIELD_COMPONENT
    TYPE(MESH_TYPE), POINTER :: MESH
    TYPE(MESH_TOPOLOGY_TYPE), POINTER :: MESH_TOPOLOGY
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_MAPPINGS_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      NUMBER_OF_COMPUTATIONAL_NODES=COMPUTATIONAL_NODES_NUMBER_GET(ERR,ERROR)
      IF(ERR/=0) GOTO 999
      my_computational_node_number=COMPUTATIONAL_NODE_NUMBER_GET(ERR,ERROR)
      IF(ERR/=0) GOTO 999        
      !Calculate the number of global and local degrees of freedom for the combined field variables and components
      NUMBER_OF_GLOBAL_DOFS=0
      NUMBER_OF_LOCAL_DOFS=0
      TOTAL_NUMBER_OF_LOCAL_DOFS=0
      NUMBER_OF_CONSTANT_DOFS=0
      NUMBER_OF_ELEMENT_DOFS=0
      NUMBER_OF_NODE_DOFS=0
      NUMBER_OF_POINT_DOFS=0
      DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
        NUMBER_OF_VARIABLE_DOFS=0
        TOTAL_NUMBER_OF_VARIABLE_DOFS=0
        NUMBER_OF_GLOBAL_VARIABLE_DOFS=0
        FIELD%VARIABLES(variable_idx)%GLOBAL_DOF_OFFSET=NUMBER_OF_GLOBAL_DOFS
        DO component_idx=1,FIELD%VARIABLES(variable_idx)%NUMBER_OF_COMPONENTS
          FIELD_COMPONENT=>FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)
          SELECT CASE(FIELD_COMPONENT%INTERPOLATION_TYPE)
          CASE(FIELD_CONSTANT_INTERPOLATION)
            NUMBER_OF_GLOBAL_DOFS=NUMBER_OF_GLOBAL_DOFS+1
            NUMBER_OF_LOCAL_DOFS=NUMBER_OF_LOCAL_DOFS+1
            TOTAL_NUMBER_OF_LOCAL_DOFS=TOTAL_NUMBER_OF_LOCAL_DOFS+1
            NUMBER_OF_CONSTANT_DOFS=NUMBER_OF_CONSTANT_DOFS+1
            NUMBER_OF_VARIABLE_DOFS=NUMBER_OF_VARIABLE_DOFS+1
            TOTAL_NUMBER_OF_VARIABLE_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS+1
            NUMBER_OF_GLOBAL_VARIABLE_DOFS=NUMBER_OF_GLOBAL_VARIABLE_DOFS+1
          CASE(FIELD_ELEMENT_BASED_INTERPOLATION)
            DOMAIN=>FIELD_COMPONENT%DOMAIN
            mesh_component_idx=DOMAIN%MESH_COMPONENT_NUMBER
            MESH=>DOMAIN%MESH
            MESH_TOPOLOGY=>MESH%TOPOLOGY(mesh_component_idx)%PTR
            DOMAIN_TOPOLOGY=>DOMAIN%TOPOLOGY
            NUMBER_OF_GLOBAL_DOFS=NUMBER_OF_GLOBAL_DOFS+MESH_TOPOLOGY%ELEMENTS%NUMBER_OF_ELEMENTS
            NUMBER_OF_LOCAL_DOFS=NUMBER_OF_LOCAL_DOFS+DOMAIN_TOPOLOGY%ELEMENTS%NUMBER_OF_ELEMENTS
            TOTAL_NUMBER_OF_LOCAL_DOFS=TOTAL_NUMBER_OF_LOCAL_DOFS+DOMAIN_TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS
            NUMBER_OF_ELEMENT_DOFS=NUMBER_OF_ELEMENT_DOFS+DOMAIN_TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS
            NUMBER_OF_VARIABLE_DOFS=NUMBER_OF_VARIABLE_DOFS+DOMAIN_TOPOLOGY%ELEMENTS%NUMBER_OF_ELEMENTS
            TOTAL_NUMBER_OF_VARIABLE_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS+DOMAIN_TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS
            NUMBER_OF_GLOBAL_VARIABLE_DOFS=NUMBER_OF_GLOBAL_VARIABLE_DOFS+MESH_TOPOLOGY%ELEMENTS%NUMBER_OF_ELEMENTS
          CASE(FIELD_NODE_BASED_INTERPOLATION)
            DOMAIN=>FIELD_COMPONENT%DOMAIN
            mesh_component_idx=DOMAIN%MESH_COMPONENT_NUMBER
            MESH=>DOMAIN%MESH
            MESH_TOPOLOGY=>MESH%TOPOLOGY(mesh_component_idx)%PTR
            DOMAIN_TOPOLOGY=>DOMAIN%TOPOLOGY
            NUMBER_OF_GLOBAL_DOFS=NUMBER_OF_GLOBAL_DOFS+MESH_TOPOLOGY%DOFS%NUMBER_OF_DOFS
            NUMBER_OF_LOCAL_DOFS=NUMBER_OF_LOCAL_DOFS+DOMAIN_TOPOLOGY%DOFS%NUMBER_OF_DOFS
            TOTAL_NUMBER_OF_LOCAL_DOFS=TOTAL_NUMBER_OF_LOCAL_DOFS+DOMAIN_TOPOLOGY%DOFS%TOTAL_NUMBER_OF_DOFS
            NUMBER_OF_NODE_DOFS=NUMBER_OF_NODE_DOFS+DOMAIN_TOPOLOGY%DOFS%TOTAL_NUMBER_OF_DOFS
            NUMBER_OF_VARIABLE_DOFS=NUMBER_OF_VARIABLE_DOFS+DOMAIN_TOPOLOGY%DOFS%NUMBER_OF_DOFS
            TOTAL_NUMBER_OF_VARIABLE_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS+DOMAIN_TOPOLOGY%DOFS%TOTAL_NUMBER_OF_DOFS
            NUMBER_OF_GLOBAL_VARIABLE_DOFS=NUMBER_OF_GLOBAL_VARIABLE_DOFS+MESH_TOPOLOGY%DOFS%NUMBER_OF_DOFS
          CASE(FIELD_GRID_POINT_BASED_INTERPOLATION)
            CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
          CASE(FIELD_GAUSS_POINT_BASED_INTERPOLATION)
            CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The interpolation type of "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)%INTERPOLATION_TYPE, &
              & "*",ERR,ERROR))//" is invalid for component number "//TRIM(NUMBER_TO_VSTRING(component_idx,"*",ERR,ERROR))// &
              & " of variable number "//TRIM(NUMBER_TO_VSTRING(variable_idx,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ENDDO !component_idx
        ALLOCATE(FIELD%VARIABLES(variable_idx)%DOF_LIST(TOTAL_NUMBER_OF_VARIABLE_DOFS),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dof list",ERR,ERROR,*999)
        FIELD%VARIABLES(variable_idx)%NUMBER_OF_DOFS=NUMBER_OF_VARIABLE_DOFS
        FIELD%VARIABLES(variable_idx)%TOTAL_NUMBER_OF_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS
        FIELD%VARIABLES(variable_idx)%NUMBER_OF_GLOBAL_DOFS=NUMBER_OF_GLOBAL_VARIABLE_DOFS
      ENDDO !variable_idx
      !Allocate the mapping arrays
      ALLOCATE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(2,TOTAL_NUMBER_OF_LOCAL_DOFS),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate dof to parameter map",ERR,ERROR,*999)
      ALLOCATE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP%VARIABLE_DOF(TOTAL_NUMBER_OF_LOCAL_DOFS),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate variable dof map",ERR,ERROR,*999)
      FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NUMBER_OF_DOFS=TOTAL_NUMBER_OF_LOCAL_DOFS
      IF(NUMBER_OF_CONSTANT_DOFS>0) THEN
        ALLOCATE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP%CONSTANT_DOF2PARAM_MAP(2,NUMBER_OF_CONSTANT_DOFS),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate dof to parameter constant map",ERR,ERROR,*999)
        FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NUMBER_OF_CONSTANT_DOFS=NUMBER_OF_CONSTANT_DOFS
      ENDIF
      IF(NUMBER_OF_ELEMENT_DOFS>0) THEN
        ALLOCATE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP%ELEMENT_DOF2PARAM_MAP(3,NUMBER_OF_ELEMENT_DOFS),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate dof to parameter element map",ERR,ERROR,*999)
        FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NUMBER_OF_ELEMENT_DOFS=NUMBER_OF_ELEMENT_DOFS
      ENDIF
      IF(NUMBER_OF_NODE_DOFS>0) THEN
        ALLOCATE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP(4,NUMBER_OF_NODE_DOFS),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate dof to parameter node map",ERR,ERROR,*999)
        FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NUMBER_OF_NODE_DOFS=NUMBER_OF_NODE_DOFS
      ENDIF
      IF(NUMBER_OF_POINT_DOFS>0) THEN
        ALLOCATE(FIELD%MAPPINGS%DOF_TO_PARAM_MAP%POINT_DOF2PARAM_MAP(3,NUMBER_OF_POINT_DOFS),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate dof to parameter point map",ERR,ERROR,*999)
        FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NUMBER_OF_POINT_DOFS=NUMBER_OF_POINT_DOFS
      ENDIF      
      DECOMPOSITION=>FIELD%DECOMPOSITION
      FIELD_DOFS_MAPPING=>FIELD%MAPPINGS%DOMAIN_MAPPING
      ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(NUMBER_OF_GLOBAL_DOFS),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate dofs mapping global to local map",ERR,ERROR,*999)
      FIELD_DOFS_MAPPING%NUMBER_OF_GLOBAL=NUMBER_OF_GLOBAL_DOFS
      GLOBAL_DOFS_OFFSET=0
      ALLOCATE(LOCAL_DOFS_OFFSETS(0:DECOMPOSITION%NUMBER_OF_DOMAINS-1),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate local dofs offsets",ERR,ERROR,*999)
      LOCAL_DOFS_OFFSETS=0
      ALLOCATE(VARIABLE_LOCAL_DOFS_OFFSETS(0:DECOMPOSITION%NUMBER_OF_DOMAINS-1),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate variable local dofs offsets",ERR,ERROR,*999)
      constant_nyy=0
      element_nyy=0
      node_nyy=0
      point_nyy=0
      !Calculate the local and global numbers and set up the mappings
      DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
        NUMBER_OF_VARIABLE_DOFS=0
        TOTAL_NUMBER_OF_VARIABLE_DOFS=0
        VARIABLE_GLOBAL_DOFS_OFFSET=0
        VARIABLE_LOCAL_DOFS_OFFSETS=0
        FIELD_VARIABLE_DOFS_MAPPING=>FIELD%VARIABLES(variable_idx)%DOMAIN_MAPPING
        IF(ASSOCIATED(FIELD_VARIABLE_DOFS_MAPPING)) THEN
          ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(FIELD%VARIABLES(variable_idx)%NUMBER_OF_GLOBAL_DOFS),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate variable dofs mapping global to local map",ERR,ERROR,*999)
          FIELD_VARIABLE_DOFS_MAPPING%NUMBER_OF_GLOBAL=FIELD%VARIABLES(variable_idx)%NUMBER_OF_GLOBAL_DOFS
        ENDIF
        DO component_idx=1,FIELD%VARIABLES(variable_idx)%NUMBER_OF_COMPONENTS
          FIELD_COMPONENT=>FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)
          SELECT CASE(FIELD_COMPONENT%INTERPOLATION_TYPE)
          CASE(FIELD_CONSTANT_INTERPOLATION)
            global_ny=1+GLOBAL_DOFS_OFFSET
            !Allocate and set up global to local domain map for field mapping
            CALL DOMAIN_MAPPINGS_MAPPING_GLOBAL_INITIALISE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny),ERR,ERROR,*999)
            NUMBER_OF_DOMAINS=NUMBER_OF_COMPUTATIONAL_NODES !Constant is in all domains
            ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_NUMBER(NUMBER_OF_DOMAINS),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map local number",ERR,ERROR,*999)
            ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%DOMAIN_NUMBER(NUMBER_OF_DOMAINS),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map domain number",ERR,ERROR,*999)
            ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_TYPE(NUMBER_OF_DOMAINS),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map domain number",ERR,ERROR,*999)
            !A constant dof is mapped to all domains.
            FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%NUMBER_OF_DOMAINS=NUMBER_OF_DOMAINS
            DO domain_idx=1,NUMBER_OF_DOMAINS
              domain_no=domain_idx-1
              FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_NUMBER(domain_idx)=1+LOCAL_DOFS_OFFSETS(domain_no)
              FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%DOMAIN_NUMBER(domain_idx)=domain_no
              FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_TYPE(domain_idx)=DOMAIN_LOCAL_INTERNAL
            ENDDO !domain_idx
            local_ny=1+LOCAL_DOFS_OFFSETS(my_computational_node_number)
            variable_local_ny=1+VARIABLE_LOCAL_DOFS_OFFSETS(my_computational_node_number)
            NUMBER_OF_VARIABLE_DOFS=NUMBER_OF_VARIABLE_DOFS+1
            FIELD%VARIABLES(variable_idx)%DOF_LIST(NUMBER_OF_VARIABLE_DOFS)=local_ny
            TOTAL_NUMBER_OF_VARIABLE_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS+1
            !Allocate and set up global to local domain map for variable mapping
            IF(ASSOCIATED(FIELD_VARIABLE_DOFS_MAPPING)) THEN
              variable_global_ny=1+VARIABLE_GLOBAL_DOFS_OFFSET
              CALL DOMAIN_MAPPINGS_MAPPING_GLOBAL_INITIALISE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny), &
                & ERR,ERROR,*999)
              NUMBER_OF_DOMAINS=NUMBER_OF_COMPUTATIONAL_NODES !Constant is in all domains
              ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_NUMBER(NUMBER_OF_DOMAINS), &
                & STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map local number",ERR,ERROR,*999)
              ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%DOMAIN_NUMBER(NUMBER_OF_DOMAINS), &
                & STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map domain number",ERR,ERROR,*999)
              ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_TYPE(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map domain number",ERR,ERROR,*999)
              !A constant dof is mapped to all domains.
              FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%NUMBER_OF_DOMAINS=NUMBER_OF_DOMAINS
              DO domain_idx=1,NUMBER_OF_DOMAINS
                domain_no=domain_idx-1
                FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_NUMBER(domain_idx)= &
                  & 1+VARIABLE_LOCAL_DOFS_OFFSETS(domain_no)
                FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%DOMAIN_NUMBER(domain_idx)=domain_no
                FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_TYPE(domain_idx)=DOMAIN_LOCAL_INTERNAL
              ENDDO !domain_idx
            ENDIF
            constant_nyy=constant_nyy+1
            !Allocate and setup dof to parameter map
            FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(1,local_ny)=FIELD_CONSTANT_DOF_TYPE
            FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(2,local_ny)=constant_nyy
            FIELD%MAPPINGS%DOF_TO_PARAM_MAP%VARIABLE_DOF(local_ny)=variable_local_ny
            FIELD%MAPPINGS%DOF_TO_PARAM_MAP%CONSTANT_DOF2PARAM_MAP(1,constant_nyy)=component_idx
            FIELD%MAPPINGS%DOF_TO_PARAM_MAP%CONSTANT_DOF2PARAM_MAP(2,constant_nyy)=variable_idx
            !Allocate and setup reverse parameter to dof map
            FIELD_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_CONSTANT_PARAMETERS=1
            FIELD_COMPONENT%PARAM_TO_DOF_MAP%CONSTANT_PARAM2DOF_MAP(0)=local_ny
            FIELD_COMPONENT%PARAM_TO_DOF_MAP%CONSTANT_PARAM2DOF_MAP(1)=variable_local_ny
            !Adjust the offsets
            GLOBAL_DOFS_OFFSET=GLOBAL_DOFS_OFFSET+1
            VARIABLE_GLOBAL_DOFS_OFFSET=VARIABLE_GLOBAL_DOFS_OFFSET+1
            LOCAL_DOFS_OFFSETS=LOCAL_DOFS_OFFSETS+1
            VARIABLE_LOCAL_DOFS_OFFSETS=VARIABLE_LOCAL_DOFS_OFFSETS+1
          CASE(FIELD_ELEMENT_BASED_INTERPOLATION)
            DOMAIN=>FIELD_COMPONENT%DOMAIN
            ELEMENTS_MAPPING=>DOMAIN%MAPPINGS%ELEMENTS
            mesh_component_idx=DOMAIN%MESH_COMPONENT_NUMBER
            MESH=>DOMAIN%MESH
            MESH_TOPOLOGY=>MESH%TOPOLOGY(mesh_component_idx)%PTR
            DOMAIN_TOPOLOGY=>DOMAIN%TOPOLOGY
            DECOMPOSITION=>DOMAIN%DECOMPOSITION
            NUMBER_OF_ELEMENT_DOFS=NUMBER_OF_ELEMENT_DOFS+DOMAIN_TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS
            !Allocate parameter to dof map for this field variable component
            DOFS_MAPPING=>DOMAIN%MAPPINGS%ELEMENTS
            ALLOCATE(FIELD_COMPONENT%PARAM_TO_DOF_MAP%ELEMENT_PARAM2DOF_MAP(DOMAIN_TOPOLOGY%ELEMENTS% &
              & TOTAL_NUMBER_OF_ELEMENTS,0:1),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field component parameter to dof element map",ERR,ERROR,*999)
            FIELD_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_ELEMENT_PARAMETERS=DOMAIN_TOPOLOGY%ELEMENTS%TOTAL_NUMBER_OF_ELEMENTS
            !Handle global dofs domain mapping
            DO ny=1,ELEMENTS_MAPPING%NUMBER_OF_GLOBAL
              !Handle field mappings
              global_ny=ny+GLOBAL_DOFS_OFFSET
              TOTAL_NUMBER_OF_VARIABLE_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS+1
              CALL DOMAIN_MAPPINGS_MAPPING_GLOBAL_INITIALISE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny),ERR,ERROR,*999)
              NUMBER_OF_DOMAINS=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%NUMBER_OF_DOMAINS
              ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_NUMBER(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map local number",ERR,ERROR,*999)
              ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%DOMAIN_NUMBER(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map domain number",ERR,ERROR,*999)
              ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_TYPE(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map domain number",ERR,ERROR,*999)
              FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%NUMBER_OF_DOMAINS=NUMBER_OF_DOMAINS
              DO domain_idx=1,NUMBER_OF_DOMAINS
                domain_no=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_NUMBER(domain_idx)= &
                  & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_NUMBER(domain_idx)+LOCAL_DOFS_OFFSETS(domain_no)
                FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%DOMAIN_NUMBER(domain_idx)= &
                  & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_TYPE(domain_idx)= &
                  & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_TYPE(domain_idx)
              ENDDO !domain_idx
              !Handle field variable mappings
              IF(ASSOCIATED(FIELD_VARIABLE_DOFS_MAPPING)) THEN
                variable_global_ny=ny+VARIABLE_GLOBAL_DOFS_OFFSET
                CALL DOMAIN_MAPPINGS_MAPPING_GLOBAL_INITIALISE(FIELD_VARIABLE_DOFS_MAPPING% &
                  & GLOBAL_TO_LOCAL_MAP(variable_global_ny),ERR,ERROR,*999)
                NUMBER_OF_DOMAINS=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%NUMBER_OF_DOMAINS
                ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_NUMBER(NUMBER_OF_DOMAINS), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map local number", &
                  & ERR,ERROR,*999)
                ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%DOMAIN_NUMBER(NUMBER_OF_DOMAINS), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map domain number", &
                  & ERR,ERROR,*999)
                ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_TYPE(NUMBER_OF_DOMAINS), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map domain number", &
                  & ERR,ERROR,*999)
                FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%NUMBER_OF_DOMAINS=NUMBER_OF_DOMAINS
                DO domain_idx=1,NUMBER_OF_DOMAINS
                  domain_no=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                  FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_NUMBER(domain_idx)= &
                    & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_NUMBER(domain_idx)+VARIABLE_LOCAL_DOFS_OFFSETS(domain_no)
                  FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%DOMAIN_NUMBER(domain_idx)= &
                    & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                  FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_TYPE(domain_idx)= &
                    & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_TYPE(domain_idx)
                ENDDO !domain_idx
              ENDIF
            ENDDO !ny
            !Handle local dofs domain mapping
            DO ne=1,ELEMENTS_MAPPING%TOTAL_NUMBER_OF_LOCAL
              local_ny=ne+LOCAL_DOFS_OFFSETS(my_computational_node_number)
              variable_local_ny=ne+VARIABLE_LOCAL_DOFS_OFFSETS(my_computational_node_number)
              NUMBER_OF_VARIABLE_DOFS=NUMBER_OF_VARIABLE_DOFS+1
              FIELD%VARIABLES(variable_idx)%DOF_LIST(NUMBER_OF_VARIABLE_DOFS)=local_ny
              element_nyy=element_nyy+1
              !Allocate and setup dof to parameter map
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(1,local_ny)=FIELD_ELEMENT_DOF_TYPE
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(2,local_ny)=element_nyy
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%VARIABLE_DOF(local_ny)=variable_local_ny
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%ELEMENT_DOF2PARAM_MAP(1,element_nyy)=ne
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%ELEMENT_DOF2PARAM_MAP(2,element_nyy)=component_idx
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%ELEMENT_DOF2PARAM_MAP(3,element_nyy)=variable_idx
              !Handle local dofs
              FIELD_COMPONENT%PARAM_TO_DOF_MAP%ELEMENT_PARAM2DOF_MAP(ne,0)=local_ny              
              FIELD_COMPONENT%PARAM_TO_DOF_MAP%ELEMENT_PARAM2DOF_MAP(ne,1)=variable_local_ny              
            ENDDO !ne
            !Adjust the offsets            
            GLOBAL_DOFS_OFFSET=GLOBAL_DOFS_OFFSET+ELEMENTS_MAPPING%NUMBER_OF_GLOBAL
            VARIABLE_GLOBAL_DOFS_OFFSET=VARIABLE_GLOBAL_DOFS_OFFSET+ELEMENTS_MAPPING%NUMBER_OF_GLOBAL
            LOCAL_DOFS_OFFSETS=LOCAL_DOFS_OFFSETS+ELEMENTS_MAPPING%NUMBER_OF_DOMAIN_LOCAL
            VARIABLE_LOCAL_DOFS_OFFSETS=VARIABLE_LOCAL_DOFS_OFFSETS+ELEMENTS_MAPPING%NUMBER_OF_DOMAIN_LOCAL
          CASE(FIELD_NODE_BASED_INTERPOLATION)
            DOMAIN=>FIELD_COMPONENT%DOMAIN
            mesh_component_idx=DOMAIN%MESH_COMPONENT_NUMBER
            MESH=>DOMAIN%MESH
            MESH_TOPOLOGY=>MESH%TOPOLOGY(mesh_component_idx)%PTR
            DOMAIN_TOPOLOGY=>DOMAIN%TOPOLOGY
            DECOMPOSITION=>DOMAIN%DECOMPOSITION
            NUMBER_OF_NODE_DOFS=NUMBER_OF_NODE_DOFS+DOMAIN_TOPOLOGY%DOFS%TOTAL_NUMBER_OF_DOFS
            DOFS_MAPPING=>DOMAIN%MAPPINGS%DOFS
            !Allocate parameter to dof map for this field variable component
            MAX_NUMBER_OF_DERIVATIVES=-1
            DO np=1,DOMAIN_TOPOLOGY%NODES%TOTAL_NUMBER_OF_NODES
              IF(DOMAIN_TOPOLOGY%NODES%NODES(np)%NUMBER_OF_DERIVATIVES>MAX_NUMBER_OF_DERIVATIVES) &
                & MAX_NUMBER_OF_DERIVATIVES=DOMAIN_TOPOLOGY%NODES%NODES(np)%NUMBER_OF_DERIVATIVES
            ENDDO !np
            ALLOCATE(FIELD_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(MAX_NUMBER_OF_DERIVATIVES, &
              & DOMAIN_TOPOLOGY%NODES%TOTAL_NUMBER_OF_NODES,0:1),STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field component parameter to dof node map",ERR,ERROR,*999)
            FIELD_COMPONENT%PARAM_TO_DOF_MAP%NUMBER_OF_NODE_PARAMETERS=DOMAIN_TOPOLOGY%NODES%TOTAL_NUMBER_OF_NODES
            FIELD_COMPONENT%PARAM_TO_DOF_MAP%MAX_NUMBER_OF_DERIVATIVES=MAX_NUMBER_OF_DERIVATIVES
            !Handle global dofs domain mapping
            DO ny=1,DOFS_MAPPING%NUMBER_OF_GLOBAL
              !Handle field mapping
              global_ny=ny+GLOBAL_DOFS_OFFSET
              TOTAL_NUMBER_OF_VARIABLE_DOFS=TOTAL_NUMBER_OF_VARIABLE_DOFS+1
              CALL DOMAIN_MAPPINGS_MAPPING_GLOBAL_INITIALISE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny),ERR,ERROR,*999)
              NUMBER_OF_DOMAINS=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%NUMBER_OF_DOMAINS
              ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_NUMBER(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map local number",ERR,ERROR,*999)
              ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%DOMAIN_NUMBER(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map domain number",ERR,ERROR,*999)
              ALLOCATE(FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_TYPE(NUMBER_OF_DOMAINS),STAT=ERR)
              IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field dofs global to local map domain number",ERR,ERROR,*999)
              FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%NUMBER_OF_DOMAINS=NUMBER_OF_DOMAINS
              DO domain_idx=1,NUMBER_OF_DOMAINS
                domain_no=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_NUMBER(domain_idx)= &
                  & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_NUMBER(domain_idx)+LOCAL_DOFS_OFFSETS(domain_no)
                FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%DOMAIN_NUMBER(domain_idx)= &
                  & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                FIELD_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(global_ny)%LOCAL_TYPE(domain_idx)= &
                  & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_TYPE(domain_idx)
              ENDDO !domain_idx
              !Handle variable mapping
              IF(ASSOCIATED(FIELD_VARIABLE_DOFS_MAPPING)) THEN
                variable_global_ny=ny+VARIABLE_GLOBAL_DOFS_OFFSET
                CALL DOMAIN_MAPPINGS_MAPPING_GLOBAL_INITIALISE(FIELD_VARIABLE_DOFS_MAPPING% &
                  & GLOBAL_TO_LOCAL_MAP(variable_global_ny),ERR,ERROR,*999)
                NUMBER_OF_DOMAINS=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%NUMBER_OF_DOMAINS
                ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_NUMBER(NUMBER_OF_DOMAINS), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map local number",ERR,ERROR,*999)
                ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%DOMAIN_NUMBER(NUMBER_OF_DOMAINS), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map domain number",ERR,ERROR,*999)
                ALLOCATE(FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_TYPE(NUMBER_OF_DOMAINS),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable dofs global to local map domain number",ERR,ERROR,*999)
                FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%NUMBER_OF_DOMAINS=NUMBER_OF_DOMAINS
                DO domain_idx=1,NUMBER_OF_DOMAINS
                  domain_no=DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                  FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_NUMBER(domain_idx)= &
                    & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_NUMBER(domain_idx)+VARIABLE_LOCAL_DOFS_OFFSETS(domain_no)
                  FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%DOMAIN_NUMBER(domain_idx)= &
                    & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%DOMAIN_NUMBER(domain_idx)
                  FIELD_VARIABLE_DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(variable_global_ny)%LOCAL_TYPE(domain_idx)= &
                    & DOFS_MAPPING%GLOBAL_TO_LOCAL_MAP(ny)%LOCAL_TYPE(domain_idx)
                ENDDO !domain_idx
              ENDIF
            ENDDO !ny (global)
            !Handle local dofs domain mapping
            DO ny=1,DOFS_MAPPING%TOTAL_NUMBER_OF_LOCAL
              local_ny=ny+LOCAL_DOFS_OFFSETS(my_computational_node_number)
              variable_local_ny=ny+VARIABLE_LOCAL_DOFS_OFFSETS(my_computational_node_number)
              NUMBER_OF_VARIABLE_DOFS=NUMBER_OF_VARIABLE_DOFS+1
              FIELD%VARIABLES(variable_idx)%DOF_LIST(NUMBER_OF_VARIABLE_DOFS)=local_ny
              node_nyy=node_nyy+1
              nk=DOMAIN%TOPOLOGY%DOFS%DOF_INDEX(1,ny)
              np=DOMAIN%TOPOLOGY%DOFS%DOF_INDEX(2,ny)
              !Allocate and setup dof to parameter map
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(1,local_ny)=FIELD_NODE_DOF_TYPE
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%DOF_TYPE(2,local_ny)=node_nyy
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%VARIABLE_DOF(local_ny)=variable_local_ny
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP(1,node_nyy)=nk
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP(2,node_nyy)=np
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP(3,node_nyy)=component_idx
              FIELD%MAPPINGS%DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP(4,node_nyy)=variable_idx
              !Handle local dofs
              FIELD_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(nk,np,0)=local_ny              
              FIELD_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(nk,np,1)=variable_local_ny              
            ENDDO !ny
            !Adjust the offsets            
            GLOBAL_DOFS_OFFSET=GLOBAL_DOFS_OFFSET+DOFS_MAPPING%NUMBER_OF_GLOBAL
            VARIABLE_GLOBAL_DOFS_OFFSET=VARIABLE_GLOBAL_DOFS_OFFSET+DOFS_MAPPING%NUMBER_OF_GLOBAL
            LOCAL_DOFS_OFFSETS=LOCAL_DOFS_OFFSETS+DOFS_MAPPING%NUMBER_OF_DOMAIN_LOCAL
            VARIABLE_LOCAL_DOFS_OFFSETS=VARIABLE_LOCAL_DOFS_OFFSETS+DOFS_MAPPING%NUMBER_OF_DOMAIN_LOCAL
          CASE(FIELD_GRID_POINT_BASED_INTERPOLATION)
            CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
          CASE(FIELD_GAUSS_POINT_BASED_INTERPOLATION)
            CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The interpolation type of "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)%INTERPOLATION_TYPE, &
              & "*",ERR,ERROR))//" is invalid for component number "//TRIM(NUMBER_TO_VSTRING(component_idx,"*",ERR,ERROR))// &
              & " of variable number "//TRIM(NUMBER_TO_VSTRING(variable_idx,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ENDDO !component_idx
        IF(ASSOCIATED(FIELD_VARIABLE_DOFS_MAPPING)) THEN
          CALL DOMAIN_MAPPINGS_LOCAL_FROM_GLOBAL_CALCULATE(FIELD_VARIABLE_DOFS_MAPPING,ERR,ERROR,*999)
        ENDIF
      ENDDO !variable_idx

      CALL DOMAIN_MAPPINGS_LOCAL_FROM_GLOBAL_CALCULATE(FIELD%MAPPINGS%DOMAIN_MAPPING,ERR,ERROR,*999)

      IF(ALLOCATED(LOCAL_DOFS_OFFSETS)) DEALLOCATE(LOCAL_DOFS_OFFSETS)
      IF(ALLOCATED(VARIABLE_LOCAL_DOFS_OFFSETS)) DEALLOCATE(VARIABLE_LOCAL_DOFS_OFFSETS)
      
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_MAPPINGS_CALCULATE")
    RETURN
999 IF(ALLOCATED(LOCAL_DOFS_OFFSETS)) DEALLOCATE(LOCAL_DOFS_OFFSETS)
    IF(ALLOCATED(VARIABLE_LOCAL_DOFS_OFFSETS)) DEALLOCATE(VARIABLE_LOCAL_DOFS_OFFSETS)
    CALL ERRORS("FIELD_MAPPINGS_CALCULATE",ERR,ERROR)
    CALL EXITS("FIELD_MAPPINGS_CALCULATE")
    RETURN 1
  END SUBROUTINE FIELD_MAPPINGS_CALCULATE

  !
  !================================================================================================================================
  !

  !>Finalises the dofs to parameters  mapping for a field and deallocates all memory. 
  SUBROUTINE FIELD_MAPPINGS_DOF_TO_PARAM_MAP_FINALISE(DOF_TO_PARAM_MAP,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_DOF_TO_PARAM_MAP_TYPE) :: DOF_TO_PARAM_MAP !<The dof to parameter map to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_MAPPINGS_DOF_TO_PARAM_MAP_FINALISE",ERR,ERROR,*999)

    IF(ALLOCATED(DOF_TO_PARAM_MAP%DOF_TYPE)) DEALLOCATE(DOF_TO_PARAM_MAP%DOF_TYPE)
    IF(ALLOCATED(DOF_TO_PARAM_MAP%VARIABLE_DOF)) DEALLOCATE(DOF_TO_PARAM_MAP%VARIABLE_DOF)
    IF(ALLOCATED(DOF_TO_PARAM_MAP%CONSTANT_DOF2PARAM_MAP)) DEALLOCATE(DOF_TO_PARAM_MAP%CONSTANT_DOF2PARAM_MAP)
    IF(ALLOCATED(DOF_TO_PARAM_MAP%ELEMENT_DOF2PARAM_MAP)) DEALLOCATE(DOF_TO_PARAM_MAP%ELEMENT_DOF2PARAM_MAP)
    IF(ALLOCATED(DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP)) DEALLOCATE(DOF_TO_PARAM_MAP%NODE_DOF2PARAM_MAP)
    IF(ALLOCATED(DOF_TO_PARAM_MAP%POINT_DOF2PARAM_MAP)) DEALLOCATE(DOF_TO_PARAM_MAP%POINT_DOF2PARAM_MAP)
    DOF_TO_PARAM_MAP%NUMBER_OF_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_CONSTANT_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_ELEMENT_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_NODE_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_POINT_DOFS=0
     
    CALL EXITS("FIELD_MAPPINGS_DOF_TO_PARAM_MAP_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_MAPPINGS_DOF_TO_PARAM_MAP_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_MAPPINGS_DOF_TO_PARAM_FMAP_INALISE")
    RETURN 1
  END SUBROUTINE FIELD_MAPPINGS_DOF_TO_PARAM_MAP_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the dofs to parameters mappings for a field.
  SUBROUTINE FIELD_MAPPINGS_DOF_TO_PARAM_MAP_INITIALISE(DOF_TO_PARAM_MAP,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_DOF_TO_PARAM_MAP_TYPE) :: DOF_TO_PARAM_MAP !<The dof to parameter map to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_MAPPINGS_DOF_TO_PARAM_INITIALISE",ERR,ERROR,*999)

    DOF_TO_PARAM_MAP%NUMBER_OF_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_CONSTANT_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_ELEMENT_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_NODE_DOFS=0
    DOF_TO_PARAM_MAP%NUMBER_OF_POINT_DOFS=0
    
    CALL EXITS("FIELD_MAPPINGS_DOF_TO_PARAM_MAP_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_MAPPINGS_DOF_TO_PARAM_MAP_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_MAPPINGS_DOF_TO_PARAM_MAP_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_MAPPINGS_DOF_TO_PARAM_MAP_INITIALISE

  !
  !================================================================================================================================
  !
 
!!MERGE: Check finished. Make into a subroutine. Return a field pointer!
 
  !>Gets the geometric field for a field identified by a pointer.
  FUNCTION FIELD_GEOMETRIC_FIELD_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the geometric field for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    TYPE(FIELD_TYPE) :: FIELD_GEOMETRIC_FIELD_GET !<A pointer to the geometric field
    !Local Variables

   
    CALL ENTERS("FIELD_GEOMETRIC_FIELD_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_GEOMETRIC_FIELD_GET=FIELD%GEOMETRIC_FIELD
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_FIELD_GET")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_FIELD_GET",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_FIELD_GET")
    RETURN 
  END FUNCTION FIELD_GEOMETRIC_FIELD_GET

  !
  !================================================================================================================================
  !

  !>Sets/changes the geometric field for a field identified by a user number.
  SUBROUTINE FIELD_GEOMETRIC_FIELD_SET_NUMBER(USER_NUMBER,REGION,GEOMETRIC_FIELD,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field
    TYPE(REGION_TYPE), POINTER :: REGION !<The region of the field
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD !<A pointer to the geometric field to associate with this field
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_GEOMETRIC_FIELD_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_GEOMETRIC_FIELD_SET_PTR(FIELD,GEOMETRIC_FIELD,ERR,ERROR,*999)
       
    CALL EXITS("FIELD_GEOMETRIC_FIELD_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_FIELD_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_FIELD_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_FIELD_SET_NUMBER

  !
  !================================================================================================================================
  !

  !>Sets/changes the geometric field for a field identified by a pointer.
  SUBROUTINE FIELD_GEOMETRIC_FIELD_SET_PTR(FIELD,GEOMETRIC_FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the geometric field for
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD !<A pointer to the geometric field
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

   
    CALL ENTERS("FIELD_GEOMETRIC_FIELD_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD)) THEN
          CALL FLAG_ERROR("The specified field already has a geometric field associated",ERR,ERROR,*999)
        ELSE
          IF(ASSOCIATED(FIELD%DECOMPOSITION)) THEN
            IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN
              IF(GEOMETRIC_FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
                IF(GEOMETRIC_FIELD%FIELD_FINISHED) THEN
                  IF(FIELD%DECOMPOSITION%MESH%USER_NUMBER==GEOMETRIC_FIELD%DECOMPOSITION%MESH%USER_NUMBER) THEN
                    SELECT CASE(FIELD%TYPE)
                    CASE(FIELD_FIBRE_TYPE,FIELD_GENERAL_TYPE,FIELD_MATERIAL_TYPE)
                      FIELD%GEOMETRIC_FIELD=>GEOMETRIC_FIELD
                    CASE(FIELD_GEOMETRIC_TYPE)
                      CALL FLAG_ERROR("Can not set the geometric field for a geometric field",ERR,ERROR,*999)
                    CASE DEFAULT
                      LOCAL_ERROR="A field type "//TRIM(NUMBER_TO_VSTRING(FIELD%TYPE,"*",ERR,ERROR))//" is not valid"
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                    END SELECT
                  ELSE
                    LOCAL_ERROR="The specified field is decomposed on mesh user number "// &
                      & TRIM(NUMBER_TO_VSTRING(FIELD%DECOMPOSITION%MESH%USER_NUMBER,"*",ERR,ERROR))// &
                      & " and the geometric field is decomposed on mesh user number "// &
                      & TRIM(NUMBER_TO_VSTRING(GEOMETRIC_FIELD%DECOMPOSITION%MESH%USER_NUMBER,"*",ERR,ERROR))// &
                      & ". The two fields must use the same mesh"
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("The specified geometric field has not been finished",ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("The specified geometric field is not a geometric field",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Geometric field is not associated",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("The field does not have a decomposition associated",ERR,ERROR,*999)
          ENDIF
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_FIELD_SET_PTR")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_FIELD_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_FIELD_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_FIELD_SET_PTR
  
  !
  !================================================================================================================================
  !

  !>Calculates the geometric parameters (line lengths, areas, volumes, scaling etc.) for a field. 
  SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_CALCULATE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<The field to calculate the geometric parameters for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_GEOMETRIC_PARAMETERS_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
          CALL FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE(FIELD,ERR,ERROR,*999)
        ELSE
          LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" is not a geometric field"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_CALCULATE")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_PARAMETERS_CALCULATE",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_CALCULATE")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_CALCULATE

  !
  !================================================================================================================================
  !

  !>Finalises the geometric parameters for a field and deallocates all memory. 
  SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_FINALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finalise the geometric parameters for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx
    TYPE(FIELD_TYPE), POINTER :: FIELD2
    
    CALL ENTERS("FIELD_GEOMETRIC_PARAMETERS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD_PARAMETERS)) THEN
        !Nullify the geometric field pointer of those fields using this geometric field.
        DO field_idx=1,FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING
          FIELD2=>FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(field_idx)%PTR
          IF(ASSOCIATED(FIELD2)) NULLIFY(FIELD2%GEOMETRIC_FIELD)
        ENDDO !field_idx
        IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING)) DEALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING)
        IF(ALLOCATED(FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS)) DEALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS)
        IF(ALLOCATED(FIELD%GEOMETRIC_FIELD_PARAMETERS%AREAS)) DEALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS%AREAS)
        IF(ALLOCATED(FIELD%GEOMETRIC_FIELD_PARAMETERS%VOLUMES)) DEALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS%VOLUMES)
        DEALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_PARAMETERS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the geometric parameters for a geometric field
  SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_INITIALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the geometric parameters for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx
    TYPE(FIELD_PTR_TYPE), POINTER :: NEW_FIELDS_USING(:)

    NULLIFY(NEW_FIELDS_USING)

    CALL ENTERS("FIELD_GEOMETRIC_PARAMETERS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
        !Field is a geometric field
        ALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate geometric field parameters",ERR,ERROR,*999)
        FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_LINES=FIELD%DECOMPOSITION%TOPOLOGY%LINES%NUMBER_OF_LINES
        FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_AREAS=0
        FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_VOLUMES=0
        ALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS(FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_LINES),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate lengths",ERR,ERROR,*999)
        FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS=0.0_DP
        !The field is a geometric field so it must use itself initiallly
        ALLOCATE(FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(1),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate fields using",ERR,ERROR,*999)
        FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(1)%PTR=>FIELD
        FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING=1
      ELSE
        !Field is not a geometric field
        NULLIFY(FIELD%GEOMETRIC_FIELD_PARAMETERS)
        IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD)) THEN
          !Set the geometric field so that it knows that this field is using it
          ALLOCATE(NEW_FIELDS_USING(FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING+1),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new fields using",ERR,ERROR,*999)
          DO field_idx=1,FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING
            NEW_FIELDS_USING(field_idx)%PTR=>FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(field_idx)%PTR
          ENDDO !field_idx
          NEW_FIELDS_USING(FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING+1)%PTR=>FIELD
          FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING=FIELD%GEOMETRIC_FIELD% &
            & GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING+1
          IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING)) &
            & DEALLOCATE(FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING)
          FIELD%GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING=>NEW_FIELDS_USING
        ELSE
          CALL FLAG_ERROR("Field does not have a geometric field associated",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_INITIALISE")
    RETURN
999 IF(ASSOCIATED(NEW_FIELDS_USING)) DEALLOCATE(NEW_FIELDS_USING)
    CALL ERRORS("FIELD_GEOMETRIC_PARAMETERS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_INITIALISE

  !
  !================================================================================================================================
  !
  
  !>Calculates the line lengths from the parameters of a geometric field. Old CMISS name LINSCA
  SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to calculate the line lengths for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR,ITERATION_NUMBER,MAXIMUM_DIFFERENCE_LINE,ng,nl
    INTEGER(INTG), PARAMETER :: LINES_MAXIMUM_NUMBER_OF_ITERATIONS=20
    INTEGER(INTG) :: GAUSS_START(4) = (/ 0,1,3,6 /)
    INTEGER(INTG) :: NUMBER_OF_GAUSS_POINTS=4
    REAL(DP) :: LAST_MAXIMUM_LENGTH_DIFFERENCE,LENGTH_DIFFERENCE,MAXIMUM_LENGTH_DIFFERENCE,XI(1),W,DERIV_NORM,LINE_LENGTH, &
      & OLD_LINE_LENGTH
! Doxygen doesn't like this    
!    REAL(DP) :: XIG(10) = (/ 0.500000000000000_DP, &
!      &                      0.211324865405187_DP,0.788675134594813_DP, &
!      &                      0.112701665379258_DP,0.500000000000000_DP,0.887298334620742_DP, &
!      &                      0.06943184420297349_DP,0.330009478207572_DP,0.669990521792428_DP,0.930568155797026_DP /)
!    REAL(DP) :: WIG(10) = (/ 1.000000000000000_DP, &
!      &                      0.500000000000000_DP,0.500000000000000_DP, &
!      &                      0.277777777777778_DP,0.444444444444444_DP,0.277777777777778_DP,
!      &                      0.173927422568727_DP,0.326072577431273_DP,0.326072577431273_DP,0.173927422568727_DP /)
    REAL(DP) :: XIG(10),WIG(10)
    REAL(DP), PARAMETER :: LINE_INCREMENT_TOLERANCE=CONVERGENCE_TOLERANCE
    LOGICAL :: ITERATE,UPDATE_FIELDS_USING
    TYPE(COORDINATE_SYSTEM_TYPE), POINTER :: COORDINATE_SYSTEM
    TYPE(FIELD_INTERPOLATED_POINT_TYPE), POINTER :: INTERPOLATED_POINT
    TYPE(FIELD_INTERPOLATION_PARAMETERS_TYPE), POINTER :: INTERPOLATION_PARAMETERS
    TYPE(VARYING_STRING) :: DUMMY_ERROR,LOCAL_ERROR

    XIG = (/ 0.500000000000000_DP, &
      &      0.211324865405187_DP,0.788675134594813_DP, &
      &      0.112701665379258_DP,0.500000000000000_DP,0.887298334620742_DP, &
      &      0.06943184420297349_DP,0.330009478207572_DP,0.669990521792428_DP,0.930568155797026_DP /)
    WIG = (/ 1.000000000000000_DP, &
      &      0.500000000000000_DP,0.500000000000000_DP, &
      &      0.277777777777778_DP,0.444444444444444_DP,0.277777777777778_DP, &
      &      0.173927422568727_DP,0.326072577431273_DP,0.326072577431273_DP,0.173927422568727_DP /)

    NULLIFY(INTERPOLATED_POINT)
    NULLIFY(INTERPOLATION_PARAMETERS)
    
    CALL ENTERS("FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
          IF(ASSOCIATED(FIELD%GEOMETRIC_FIELD_PARAMETERS)) THEN
            COORDINATE_SYSTEM=>FIELD%REGION%COORDINATE_SYSTEM
            !Iterate to find the line lengths as the line lengths depend on the scaling factors and vise versa.
            CALL FIELD_INTERPOLATION_PARAMETERS_INITIALISE(FIELD,FIELD_STANDARD_VARIABLE_TYPE,INTERPOLATION_PARAMETERS, &
              & ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINT_INITIALISE(INTERPOLATION_PARAMETERS,INTERPOLATED_POINT,ERR,ERROR,*999)
            ITERATE=.TRUE.
            ITERATION_NUMBER=0
            LAST_MAXIMUM_LENGTH_DIFFERENCE=0.0_DP
            DO WHILE(ITERATE.AND.ITERATION_NUMBER<=LINES_MAXIMUM_NUMBER_OF_ITERATIONS)
              MAXIMUM_LENGTH_DIFFERENCE=0.0_DP
              MAXIMUM_DIFFERENCE_LINE=1
              !Loop over the lines
              DO nl=1,FIELD%DECOMPOSITION%TOPOLOGY%LINES%NUMBER_OF_LINES
                CALL FIELD_INTERPOLATION_PARAMETERS_LINE_GET(FIELD_VALUES_SET_TYPE,nl,INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
                OLD_LINE_LENGTH=FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS(nl)
                LINE_LENGTH=0.0_DP
                !Integrate || dr(xi)/dt || from xi=0 to 1 to determine the arc length. 
                DO ng=1,NUMBER_OF_GAUSS_POINTS
                  XI(1)=XIG(GAUSS_START(NUMBER_OF_GAUSS_POINTS)+ng)
                  W=WIG(GAUSS_START(NUMBER_OF_GAUSS_POINTS)+ng)
                  CALL FIELD_INTERPOLATE_XI(FIRST_PART_DERIV,XI,INTERPOLATED_POINT,ERR,ERROR,*999)
                  CALL COORDINATE_DERIVATIVE_NORM(COORDINATE_SYSTEM,PART_DERIV_S1,INTERPOLATED_POINT,DERIV_NORM, &
                    & ERR,ERROR,*999)
                  LINE_LENGTH=LINE_LENGTH+W*DERIV_NORM
                ENDDO !ng
                FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS(nl)=LINE_LENGTH
                LENGTH_DIFFERENCE=ABS(LINE_LENGTH-OLD_LINE_LENGTH)/(1.0_DP+OLD_LINE_LENGTH)
                IF(LENGTH_DIFFERENCE>MAXIMUM_LENGTH_DIFFERENCE) THEN
                  MAXIMUM_LENGTH_DIFFERENCE=LENGTH_DIFFERENCE
                  MAXIMUM_DIFFERENCE_LINE=nl
                ENDIF
              ENDDO !nl
              ITERATE=MAXIMUM_LENGTH_DIFFERENCE>LINE_INCREMENT_TOLERANCE
              IF(ITERATE) THEN
                IF(ITERATION_NUMBER==1) THEN
                  LAST_MAXIMUM_LENGTH_DIFFERENCE=MAXIMUM_LENGTH_DIFFERENCE
                ELSE IF(MAXIMUM_LENGTH_DIFFERENCE<LOOSE_TOLERANCE.AND. &
                  & MAXIMUM_LENGTH_DIFFERENCE>=LAST_MAXIMUM_LENGTH_DIFFERENCE) THEN
                  !Seems to be at a numerical limit
                  ITERATE=.FALSE.
                ELSE
                  LAST_MAXIMUM_LENGTH_DIFFERENCE=MAXIMUM_LENGTH_DIFFERENCE
                ENDIF                
              ENDIF
              ITERATION_NUMBER=ITERATION_NUMBER+1
              IF(DIAGNOSTICS2) THEN
                CALL WRITE_STRING(DIAGNOSTIC_OUTPUT_TYPE,"Line iteration report:",ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Number of iterations = ",ITERATION_NUMBER,ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Maximum length difference = ",MAXIMUM_LENGTH_DIFFERENCE, &
                  & ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Difference tolerance = ",LINE_INCREMENT_TOLERANCE, &
                  ERR,ERROR,*999)
                CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Maximum difference line = ",MAXIMUM_DIFFERENCE_LINE, &
                  ERR,ERROR,*999)                      
              ENDIF
              IF(.NOT.ITERATE.OR.ITERATION_NUMBER==LINES_MAXIMUM_NUMBER_OF_ITERATIONS) THEN
                UPDATE_FIELDS_USING=.TRUE.
              ELSE
                UPDATE_FIELDS_USING=.FALSE.
              ENDIF
              CALL FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE(FIELD,UPDATE_FIELDS_USING,ERR,ERROR,*999)
            ENDDO !iterate
            CALL FIELD_INTERPOLATED_POINT_FINALISE(INTERPOLATED_POINT,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATION_PARAMETERS_FINALISE(INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
          ELSE
            LOCAL_ERROR="Geometric parameters are not associated for field number "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)            
          ENDIF
        ELSE
          LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" is not a geometric field"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF

    IF(DIAGNOSTICS1) THEN
      CALL WRITE_STRING(DIAGNOSTIC_OUTPUT_TYPE,"Line lengths:",ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Number of iterations = ",ITERATION_NUMBER,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Maximum length difference = ",MAXIMUM_LENGTH_DIFFERENCE,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Difference tolerance = ",LINE_INCREMENT_TOLERANCE,ERR,ERROR,*999)
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Maximum difference line = ",MAXIMUM_DIFFERENCE_LINE,ERR,ERROR,*999)      
      CALL WRITE_STRING_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"  Number of lines = ",FIELD%DECOMPOSITION%TOPOLOGY%LINES%NUMBER_OF_LINES, &
        & ERR,ERROR,*999)
      DO nl=1,FIELD%DECOMPOSITION%TOPOLOGY%LINES%NUMBER_OF_LINES
        CALL WRITE_STRING_FMT_TWO_VALUE(DIAGNOSTIC_OUTPUT_TYPE,"    Line ",nl,"(I8)"," length = ",FIELD% &
          & GEOMETRIC_FIELD_PARAMETERS% LENGTHS(nl),"*",ERR,ERROR,*999)
      ENDDO !nl      
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE")
    RETURN
999 IF(ASSOCIATED(INTERPOLATED_POINT)) CALL FIELD_INTERPOLATED_POINT_FINALISE(INTERPOLATED_POINT,DUMMY_ERR,DUMMY_ERROR,*999)
    IF(ASSOCIATED(INTERPOLATION_PARAMETERS)) CALL FIELD_INTERPOLATION_PARAMETERS_FINALISE(INTERPOLATION_PARAMETERS, &
      & DUMMY_ERR,DUMMY_ERROR,*999)
    CALL ERRORS("FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_LINE_LENGTHS_CALCULATE


  !
  !================================================================================================================================
  !

  !>Finalises the geometric parameters for a field and deallocates all memory. 
  SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE(FIELD,UPDATE_FIELDS_USING,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to update the scale factors for
    LOGICAL, INTENT(IN) :: UPDATE_FIELDS_USING !<If .TRUE. then update the fields that use this fields geometric parameters.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx,LAST_FIELD_IDX
    TYPE(FIELD_TYPE), POINTER :: FIELD2
    
    CALL ENTERS("FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
        IF(UPDATE_FIELDS_USING) THEN
          LAST_FIELD_IDX=FIELD%GEOMETRIC_FIELD_PARAMETERS%NUMBER_OF_FIELDS_USING
        ELSE
          LAST_FIELD_IDX=1 !The first field using will be the current field
        ENDIF
        DO field_idx=1,LAST_FIELD_IDX
          FIELD2=>FIELD%GEOMETRIC_FIELD_PARAMETERS%FIELDS_USING(field_idx)%PTR
          CALL FIELD_SCALINGS_CALCULATE(FIELD2,ERR,ERROR,*999)
        ENDDO !field_idx
      ELSE
        CALL FLAG_ERROR("Field is not geometric field",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE")
    RETURN 1
  END SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_SCALE_FACTORS_UPDATE

  !
  !================================================================================================================================
  !

!!MERGE: This should go now.
  
  !>Updates the geometric field parameters from the initial nodal positions of the mesh. Any derivative values for the nodes are calculated from an average straight line approximation.
  SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH(FIELD,MESH,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to update the geometric parameters for
    TYPE(MESH_TYPE), POINTER :: MESH !<The mesh which is generated by the generated mesh
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,component_idx2,global_np,global_np1,global_np2,nk,nk1,nk2,nl,nnl,np,np1,np2,np3,ni,nu,ny, &
      & DERIVATIVES_NUMBER_OF_LINES(8), TOTAL_NUMBER_OF_NODES_XI(3)
    REAL(DP) :: DELTA(8),VECTOR(3),LENGTH, INITIAL_POSITION(3),DELTA_COORD(3),MY_ORIGIN(3),MY_EXTENT(3),MESH_SIZE(3)
    REAL(DP), POINTER :: GEOMETRIC_PARAMETERS(:)
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES
    TYPE(DOMAIN_LINES_TYPE), POINTER :: DOMAIN_LINES
    TYPE(FIELD_VARIABLE_COMPONENT_TYPE), POINTER :: FIELD_VARIABLE_COMPONENT
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(NODES_TYPE), POINTER :: REGION_NODES
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(BASIS_TYPE), POINTER :: BASIS
    TYPE(GENERATED_MESH_REGULAR_TYPE), POINTER :: REGULAR_MESH
    
    CALL ENTERS("FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH",ERR,ERROR,*999)
    
    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(ASSOCIATED(FIELD%REGION)) THEN
          IF(ASSOCIATED(FIELD%REGION%NODES)) THEN
            REGION_NODES=>FIELD%REGION%NODES
            
            IF(ASSOCIATED(MESH)) THEN
		      IF(ASSOCIATED(MESH%GENERATED_MESH)) THEN
		        SELECT CASE(MESH%GENERATED_MESH%GENERATED_TYPE)
		        !TODO
		        CASE(1) 
		          REGULAR_MESH=>MESH%GENERATED_MESH%REGULAR_MESH
		          IF(ASSOCIATED(REGULAR_MESH)) THEN
		            BASIS=>REGULAR_MESH%BASIS
		            !Calculate sizes
		            TOTAL_NUMBER_OF_NODES_XI=1
		            DO ni=1,BASIS%NUMBER_OF_XI
		              TOTAL_NUMBER_OF_NODES_XI(ni)=(BASIS%NUMBER_OF_NODES_XI(ni)-2)*REGULAR_MESH%NUMBER_OF_ELEMENTS_XI(ni)+ &
		                & REGULAR_MESH%NUMBER_OF_ELEMENTS_XI(ni)+1
		            ENDDO !ni
		            MY_ORIGIN=0.0_DP
		            MY_EXTENT=0.0_DP
		            MY_ORIGIN(1:REGULAR_MESH%MESH_DIMENSION)=REGULAR_MESH%ORIGIN
		            MY_EXTENT(1:REGULAR_MESH%MESH_DIMENSION)=REGULAR_MESH%MAXIMUM_EXTENT
		            MESH_SIZE=MY_EXTENT
		            DO ni=1,REGULAR_MESH%BASIS%NUMBER_OF_XI
		              !This assumes that the xi directions are aligned with the coordinate directions
		              DELTA_COORD(ni)=MESH_SIZE(ni)/REAL(REGULAR_MESH%NUMBER_OF_ELEMENTS_XI(ni),DP)
		            ENDDO !ni
		            DO np3=1,TOTAL_NUMBER_OF_NODES_XI(3)
		              DO np2=1,TOTAL_NUMBER_OF_NODES_XI(2)
		                DO np1=1,TOTAL_NUMBER_OF_NODES_XI(1)
		                  np=np1+(np2-1)*TOTAL_NUMBER_OF_NODES_XI(1)+(np3-1)*TOTAL_NUMBER_OF_NODES_XI(1)*TOTAL_NUMBER_OF_NODES_XI(2)
		                  INITIAL_POSITION(1)=MY_ORIGIN(1)+REAL(np1-1,DP)*DELTA_COORD(1)
		                  INITIAL_POSITION(2)=MY_ORIGIN(2)+REAL(np2-1,DP)*DELTA_COORD(2)
		                  INITIAL_POSITION(3)=MY_ORIGIN(3)+REAL(np3-1,DP)*DELTA_COORD(3)
		                  CALL NODE_INITIAL_POSITION_SET(np,INITIAL_POSITION(1:REGULAR_MESH%MESH_DIMENSION),REGION_NODES,ERR,ERROR,*999)
		                ENDDO !np1
		              ENDDO !np2
		            ENDDO !np3
		            CALL NODES_CREATE_FINISH(MESH%REGION,ERR,ERROR,*999)
		          ELSE
		            CALL FLAG_ERROR("Regular mesh is not associated",ERR,ERROR,*999)
		          ENDIF
		        CASE DEFAULT
		          CALL FLAG_ERROR("Generated mesh type is either invalid or not implemented",ERR,ERROR,*999)
		        END SELECT
		      ELSE
		        CALL FLAG_ERROR("Generated mesh is not associated",ERR,ERROR,*999)
		      ENDIF
		    ELSE
		      CALL FLAG_ERROR("Mesh is not associated",ERR,ERROR,*999)
		    ENDIF
            
            ! TODO remove      
            IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
              FIELD_VARIABLE=>FIELD%VARIABLE_TYPE_MAP(FIELD_STANDARD_VARIABLE_TYPE)%PTR
              IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                  FIELD_VARIABLE_COMPONENT=>FIELD_VARIABLE%COMPONENTS(component_idx)
                  IF(FIELD_VARIABLE_COMPONENT%INTERPOLATION_TYPE==FIELD_NODE_BASED_INTERPOLATION) THEN
                    DOMAIN=>FIELD_VARIABLE_COMPONENT%DOMAIN
                    DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                    DOMAIN_LINES=>DOMAIN%TOPOLOGY%LINES
                    DO np=1,DOMAIN_NODES%NUMBER_OF_NODES
                      global_np=DOMAIN_NODES%NODES(np)%GLOBAL_NUMBER
                      ny=FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(1,np,0)
                      CALL FIELD_PARAMETER_SET_UPDATE_DOF(FIELD,FIELD_VALUES_SET_TYPE,ny,REGION_NODES%NODES(global_np)% &
                        & INITIAL_POSITION(component_idx),ERR,ERROR,*999)
                      IF(DOMAIN_NODES%NODES(np)%NUMBER_OF_DERIVATIVES>1) THEN
                        DERIVATIVES_NUMBER_OF_LINES=0
                        DELTA=0.0_DP
                        DO nnl=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_NODE_LINES
                          nl=DOMAIN_NODES%NODES(np)%NODE_LINES(nnl)
                          np1=DOMAIN_LINES%LINES(nl)%NODES_IN_LINE(1)
                          global_np1=DOMAIN_NODES%NODES(np1)%GLOBAL_NUMBER
                          np2=DOMAIN_LINES%LINES(nl)%NODES_IN_LINE(DOMAIN_LINES%LINES(nl)%BASIS%NUMBER_OF_NODES)
                          global_np2=DOMAIN_NODES%NODES(np2)%GLOBAL_NUMBER
                          nk1=DOMAIN_LINES%LINES(nl)%DERIVATIVES_IN_LINE(2,1)
                          nk2=DOMAIN_LINES%LINES(nl)%DERIVATIVES_IN_LINE(2,DOMAIN_LINES%LINES(nl)%BASIS%NUMBER_OF_NODES)
                          !TODO: Adjust delta calculation for polar coordinate discontinuities
                          IF(np1==np) THEN
                            DERIVATIVES_NUMBER_OF_LINES(nk1)=DERIVATIVES_NUMBER_OF_LINES(nk1)+1
                            DELTA(nk1)=DELTA(nk1)+REGION_NODES%NODES(global_np2)%INITIAL_POSITION(component_idx)- &
                              & REGION_NODES%NODES(global_np1)%INITIAL_POSITION(component_idx)
                          ELSE IF(np2==np) THEN
                            DERIVATIVES_NUMBER_OF_LINES(nk2)=DERIVATIVES_NUMBER_OF_LINES(nk2)+1
                            DELTA(nk2)=DELTA(nk2)+REGION_NODES%NODES(global_np2)%INITIAL_POSITION(component_idx)- &
                              & REGION_NODES%NODES(global_np1)%INITIAL_POSITION(component_idx)
                          ELSE
                            !Error???
                          ENDIF
                        ENDDO !nnl
                        DO nk=1,8
                          IF(DERIVATIVES_NUMBER_OF_LINES(nk)>0) THEN
                            DELTA(nk)=DELTA(nk)/REAL(DERIVATIVES_NUMBER_OF_LINES(nk),DP)
                            ny=FIELD_VARIABLE_COMPONENT%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(nk,np,0)
                            CALL FIELD_PARAMETER_SET_UPDATE_DOF(FIELD,FIELD_VALUES_SET_TYPE,ny,DELTA(nk),ERR,ERROR,*999)
                          ENDIF
                        ENDDO !nk
                      ENDIF
                    ENDDO !np
                  ELSE
                    LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(component_idx,"*",ERR,ERROR))// &
                      & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                      & " does not have node based interpolation"
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  ENDIF
                ENDDO !component_idx
                CALL FIELD_PARAMETER_SET_GET(FIELD,FIELD_VALUES_SET_TYPE,GEOMETRIC_PARAMETERS,ERR,ERROR,*999)
                !Normalise the arclength derivative vectors.
                !!TODO: Don't loop over all components somehow????
                DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                  DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                  DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                  DOMAIN_LINES=>DOMAIN%TOPOLOGY%LINES
                  DO np=1,DOMAIN_NODES%NUMBER_OF_NODES
                    DO nk=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_DERIVATIVES
                      nu=DOMAIN_NODES%NODES(np)%PARTIAL_DERIVATIVE_INDEX(nk)
                      IF(nu==PART_DERIV_S1.OR.nu==PART_DERIV_S2.OR.nu==PART_DERIV_S3) THEN
                        LENGTH=0.0_DP
                        VECTOR=0.0_DP
                        DO component_idx2=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                          ny=FIELD_VARIABLE%COMPONENTS(component_idx2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(nk,np,0)
                          VECTOR(component_idx2)=GEOMETRIC_PARAMETERS(ny)
                          LENGTH=LENGTH+VECTOR(component_idx2)**2
                        ENDDO !component_idx2
                        LENGTH=SQRT(LENGTH)
                        IF(LENGTH>ZERO_TOLERANCE) THEN
                          VECTOR=VECTOR/LENGTH
                          DO component_idx2=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                            ny=FIELD_VARIABLE%COMPONENTS(component_idx2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP(nk,np,0)
                            CALL FIELD_PARAMETER_SET_UPDATE_DOF(FIELD,FIELD_VALUES_SET_TYPE,ny,VECTOR(component_idx2), &
                              & ERR,ERROR,*999)
                          ENDDO !component_idx2
                        ENDIF
                      ENDIF
                    ENDDO !nk
                  ENDDO !np
                ENDDO !component_idx
                CALL FIELD_PARAMETER_SET_RESTORE(FIELD,FIELD_VALUES_SET_TYPE,GEOMETRIC_PARAMETERS,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_START(FIELD,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(FIELD,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              ELSE
                LOCAL_ERROR="The standard field variable is not associated for field number "// &
                  & TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" is not a geometric field"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The region nodes for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
              & " are not associated"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The region for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
            & " is not associated"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH")
    RETURN
999 CALL ERRORS("FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH",ERR,ERROR)
    CALL EXITS("FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH")
    RETURN 1   
  END SUBROUTINE FIELD_GEOMETRIC_PARAMETERS_UPDATE_FROM_INITIAL_MESH
  
  !
  !================================================================================================================================
  !
  
!!MERGE: DITTO
  
  !>Gets the mesh decomposition for a field indentified by a pointer.
  FUNCTION FIELD_MESH_DECOMPOSITION_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the decomposition for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    TYPE(DECOMPOSITION_TYPE) :: FIELD_MESH_DECOMPOSITION_GET !<A pointer to the mesh decomposition to get
    !Local Variables

    CALL ENTERS("FIELD_MESH_DECOMPOSITION_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_MESH_DECOMPOSITION_GET=FIELD%DECOMPOSITION
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_MESH_DECOMPOSITION_GET")
    RETURN
999 CALL ERRORS("FIELD_MESH_DECOMPOSITION_GET",ERR,ERROR)
    CALL EXITS("FIELD_MESH_DECOMPOSITION_GET")
    RETURN
  END FUNCTION FIELD_MESH_DECOMPOSITION_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the mesh decomposition for a field identified by a user number.
  SUBROUTINE FIELD_MESH_DECOMPOSITION_SET_NUMBER(USER_NUMBER,REGION,MESH_DECOMPOSITION,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region of the field
    TYPE(DECOMPOSITION_TYPE), POINTER :: MESH_DECOMPOSITION
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_MESH_DECOMPOSITION_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
!!Ditto for the decomposition pointer.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_MESH_DECOMPOSITION_SET_PTR(FIELD,MESH_DECOMPOSITION,ERR,ERROR,*999)
    
    CALL EXITS("FIELD_MESH_DECOMPOSITION_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_MESH_DECOMPOSITION_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_MESH_DECOMPOSITION_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_MESH_DECOMPOSITION_SET_NUMBER
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the mesh decomposition for a field indentified by a pointer.
  SUBROUTINE FIELD_MESH_DECOMPOSITION_SET_PTR(FIELD,MESH_DECOMPOSITION,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the decomposition for
    TYPE(DECOMPOSITION_TYPE), POINTER :: MESH_DECOMPOSITION !<A pointer to the mesh decomposition to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_MESH_DECOMPOSITION_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(ASSOCIATED(MESH_DECOMPOSITION)) THEN
          IF(ASSOCIATED(MESH_DECOMPOSITION%MESH)) THEN
            IF(ASSOCIATED(MESH_DECOMPOSITION%MESH%REGION)) THEN
              IF(ASSOCIATED(FIELD%REGION)) THEN
                IF(MESH_DECOMPOSITION%MESH%REGION%USER_NUMBER==FIELD%REGION%USER_NUMBER) THEN
                  FIELD%DECOMPOSITION=>MESH_DECOMPOSITION
                ELSE
                  LOCAL_ERROR="Inconsitent regions. The field is defined on region number "// &
                    & TRIM(NUMBER_TO_VSTRING(FIELD%REGION%USER_NUMBER,"*",ERR,ERROR))// &
                    & " and the mesh decomposition is defined on region number "//&
                    & TRIM(NUMBER_TO_VSTRING(MESH_DECOMPOSITION%MESH%REGION%USER_NUMBER,"*",ERR,ERROR))
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
              ELSE
                LOCAL_ERROR="Region is not associated for field number "// &
                  & TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="Region is not associated for the decomposition mesh number "// &
                & TRIM(NUMBER_TO_VSTRING(MESH_DECOMPOSITION%MESH%USER_NUMBER,"*",ERR,ERROR))
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Mesh is not associated for the mesh decomposition",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Mesh decomposition is not assocaited",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_MESH_DECOMPOSITION_SET_PTR")
    RETURN
999 CALL ERRORS("FIELD_MESH_DECOMPOSITION_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_MESH_DECOMPOSITION_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_MESH_DECOMPOSITION_SET_PTR
  
  !
  !================================================================================================================================
  !

  !>Finds the next available user number for the fields defined on the given region.
  SUBROUTINE FIELD_NEXT_NUMBER_FIND(REGION,NEXT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region
    INTEGER(INTG), INTENT(OUT) :: NEXT_NUMBER !<On exit, the next field user number in the region
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx,MAXIMUM_USER_NUMBER
    TYPE(FIELD_TYPE), POINTER :: FIELD
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FIELD_NEXT_NUMBER_FIND",ERR,ERROR,*999)

    NEXT_NUMBER=0
    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%FIELDS)) THEN
        MAXIMUM_USER_NUMBER=0
        DO field_idx=1,REGION%FIELDS%NUMBER_OF_FIELDS
          FIELD=>REGION%FIELDS%FIELDS(field_idx)%PTR
          IF(FIELD%USER_NUMBER>MAXIMUM_USER_NUMBER) THEN
            MAXIMUM_USER_NUMBER=FIELD%USER_NUMBER
          ENDIF
        ENDDO !field_idx
        NEXT_NUMBER=MAXIMUM_USER_NUMBER+1
      ELSE
        LOCAL_ERROR="The fields on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))// &
          & " are not associated"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF      
    ELSE
      CALL FLAG_ERROR("Region is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_NEXT_NUMBER_FIND")
    RETURN
999 CALL ERRORS("FIELD_NEXT_NUMBER_FIND",ERR,ERROR)
    CALL EXITS("FIELD_NEXT_NUMBER_FIND")
    RETURN 1
  END SUBROUTINE FIELD_NEXT_NUMBER_FIND
  
  !
  !================================================================================================================================
  !

!!MERGE: Ditto

  !>Gets the number of field components for a field identified by a pointer.
  FUNCTION FIELD_NUMBER_OF_COMPONENTS_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to sget the number of components
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_NUMBER_OF_COMPONENTS_GET !<The number of components to be get.
    !Local Variables

    CALL ENTERS("FIELD_NUMBER_OF_COMPONENTS_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
        FIELD_NUMBER_OF_COMPONENTS_GET=FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS 
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_NUMBER_OF_COMPONENTS_GET")
    RETURN
999 CALL ERRORS("FIELD_NUMBER_OF_COMPONENTS_GET",ERR,ERROR)
    CALL EXITS("FIELD_NUMBER_OF_COMPONENTS_GET")
    RETURN
  END FUNCTION FIELD_NUMBER_OF_COMPONENTS_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the number of field components for a field variable identified by a user and variable number.
  SUBROUTINE FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER(USER_NUMBER,REGION,NUMBER_OF_COMPONENTS,ERR,ERROR,*)

   !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    INTEGER(INTG), INTENT(IN) :: NUMBER_OF_COMPONENTS
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD
    
    CALL ENTERS("FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.

    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_NUMBER_OF_COMPONENTS_SET(FIELD,NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
               
    CALL EXITS("FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_NUMBER_OF_COMPONENTS_SET_NUMBER
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the number of field components for a field identified by a pointer.
  SUBROUTINE FIELD_NUMBER_OF_COMPONENTS_SET_PTR(FIELD,NUMBER_OF_COMPONENTS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the number of components
    INTEGER(INTG), INTENT(IN) :: NUMBER_OF_COMPONENTS !<The number of components to be set.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx
    INTEGER(INTG), ALLOCATABLE :: OLD_INTERPOLATION_TYPE(:,:),OLD_MESH_COMPONENT_NUMBER(:,:)
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_NUMBER_OF_COMPONENTS_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
          SELECT CASE(FIELD%DIMENSION)
          CASE(FIELD_SCALAR_DIMENSION_TYPE)
            IF(NUMBER_OF_COMPONENTS/=1) THEN
              LOCAL_ERROR="Scalar fields cannot have "//TRIM(NUMBER_TO_VSTRING(NUMBER_OF_COMPONENTS,"*",ERR,ERROR))//" components"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          CASE(FIELD_VECTOR_DIMENSION_TYPE)
            IF(NUMBER_OF_COMPONENTS>0) THEN
              IF(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS/=NUMBER_OF_COMPONENTS) THEN
                ALLOCATE(OLD_INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old interpolation type",ERR,ERROR,*999)
                ALLOCATE(OLD_MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old mesh component number",ERR,ERROR,*999)
                OLD_INTERPOLATION_TYPE=FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE
                OLD_MESH_COMPONENT_NUMBER=FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER
                DEALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE)
                DEALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER)
                ALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolation type",ERR,ERROR,*999)
                ALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate mesh component number",ERR,ERROR,*999)                
                IF(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS<NUMBER_OF_COMPONENTS) THEN
                  DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
                    FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(1:FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,variable_idx)= &
                      & OLD_INTERPOLATION_TYPE(1:FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,variable_idx)
                    FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS+1: &
                      & NUMBER_OF_COMPONENTS,variable_idx)=OLD_INTERPOLATION_TYPE(1,variable_idx)
                    FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(1:FIELD%CREATE_VALUES_CACHE% &
                      & NUMBER_OF_COMPONENTS,variable_idx)=OLD_MESH_COMPONENT_NUMBER(1:FIELD%CREATE_VALUES_CACHE% &
                      & NUMBER_OF_COMPONENTS,variable_idx)
                    FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS+1: &
                      & NUMBER_OF_COMPONENTS,variable_idx)=OLD_MESH_COMPONENT_NUMBER(1,variable_idx)
                  ENDDO !variable_idx
                ELSE
                  DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
                    FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(1:NUMBER_OF_COMPONENTS,variable_idx)= &
                      & OLD_INTERPOLATION_TYPE(1:NUMBER_OF_COMPONENTS,variable_idx)
                    FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(1:NUMBER_OF_COMPONENTS,variable_idx)= &
                      & OLD_MESH_COMPONENT_NUMBER(1:NUMBER_OF_COMPONENTS,variable_idx)
                  ENDDO !variable_idx
                ENDIF
                FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS=NUMBER_OF_COMPONENTS
                DEALLOCATE(OLD_INTERPOLATION_TYPE)
                DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
              ENDIF
            ELSE
              LOCAL_ERROR="Vector fields cannot have "//TRIM(NUMBER_TO_VSTRING(NUMBER_OF_COMPONENTS,"*",ERR,ERROR))//" components"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          CASE DEFAULT
            LOCAL_ERROR="Field dimension "//TRIM(NUMBER_TO_VSTRING(FIELD%DIMENSION,"*",ERR,ERROR))//" is not valid"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_NUMBER_OF_COMPONENTS_SET_PTR")
    RETURN
999 IF(ALLOCATED(OLD_INTERPOLATION_TYPE)) DEALLOCATE(OLD_INTERPOLATION_TYPE)
    IF(ALLOCATED(OLD_MESH_COMPONENT_NUMBER)) DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
    CALL ERRORS("FIELD_NUMBER_OF_COMPONENTS_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_NUMBER_OF_COMPONENTS_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_NUMBER_OF_COMPONENTS_SET_PTR
  
  !
  !================================================================================================================================
  !

!!MERGE: ditto
  
  !>Gets the number of variables for a field identified by a pointer.
  FUNCTION FIELD_NUMBER_OF_VARIABLES_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to get the number of variables for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_NUMBER_OF_VARIABLES_GET !<The number of variables to get for the field
    !Local Variables

    CALL ENTERS("FIELD_NUMBER_OF_VARIABLES_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_NUMBER_OF_VARIABLES_GET=FIELD%NUMBER_OF_VARIABLES
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_NUMBER_OF_VARIABLES_GET")
    RETURN
999 CALL ERRORS("FIELD_NUMBER_OF_VARIABLES_GET",ERR,ERROR)
    CALL EXITS("FIELD_NUMBER_OF_VARIABLES_GET")
    RETURN
  END FUNCTION FIELD_NUMBER_OF_VARIABLES_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the number of variable types for a field identified by a user number.
  SUBROUTINE FIELD_NUMBER_OF_VARIABLES_SET_NUMBER(USER_NUMBER,REGION,NUMBER_OF_VARIABLES,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    INTEGER(INTG), INTENT(IN) :: NUMBER_OF_VARIABLES !<The number of variables to set for the field
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD
    
    CALL ENTERS("FIELD_NUMBER_OF_VARIABLES_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.

    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_NUMBER_OF_VARIABLES_SET(FIELD,NUMBER_OF_VARIABLES,ERR,ERROR,*999)
               
    CALL EXITS("FIELD_NUMBER_OF_VARIABLES_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_NUMBER_OF_VARIABLES_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_NUMBER_OF_VARIABLES_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_NUMBER_OF_VARIABLES_SET_NUMBER
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the number of variables for a field identified by a pointer.
  SUBROUTINE FIELD_NUMBER_OF_VARIABLES_SET_PTR(FIELD,NUMBER_OF_VARIABLES,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the number of variables for
    INTEGER(INTG), INTENT(IN) :: NUMBER_OF_VARIABLES !<The number of variables to set for the field
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx
    INTEGER(INTG), ALLOCATABLE :: OLD_VARIABLE_TYPES(:),OLD_INTERPOLATION_TYPE(:,:),OLD_MESH_COMPONENT_NUMBER(:,:)
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_NUMBER_OF_VARIABLES_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
          SELECT CASE(FIELD%DEPENDENT_TYPE)
          CASE(FIELD_INDEPENDENT_TYPE)
            IF(NUMBER_OF_VARIABLES/=1) THEN
              LOCAL_ERROR="The number of variables ("//TRIM(NUMBER_TO_VSTRING(NUMBER_OF_VARIABLES,"*",ERR,ERROR))// &
                & ") is not valid. You can only have one variable for an independent field"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ELSE
              !Do nothing
            ENDIF
          CASE(FIELD_DEPENDENT_TYPE)
            IF(NUMBER_OF_VARIABLES>0.AND.NUMBER_OF_VARIABLES<=4) THEN
              IF(FIELD%NUMBER_OF_VARIABLES/=NUMBER_OF_VARIABLES) THEN
                ALLOCATE(OLD_VARIABLE_TYPES(FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old variable types",ERR,ERROR,*999)
                ALLOCATE(OLD_INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old interpolation type",ERR,ERROR,*999)
                ALLOCATE(OLD_MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS,FIELD%NUMBER_OF_VARIABLES), &
                  & STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate old mesh component number",ERR,ERROR,*999)
                OLD_VARIABLE_TYPES=FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES
                OLD_INTERPOLATION_TYPE=FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE
                OLD_MESH_COMPONENT_NUMBER=FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER
                DEALLOCATE(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES)
                DEALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE)
                DEALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER)
                ALLOCATE(FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate variable types",ERR,ERROR,*999)
                ALLOCATE(FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS, &
                  & NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate interpolation type",ERR,ERROR,*999)
                ALLOCATE(FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS, &
                  & NUMBER_OF_VARIABLES),STAT=ERR)
                IF(ERR/=0) CALL FLAG_ERROR("Could not allocate mesh component number",ERR,ERROR,*999)
                IF(FIELD%NUMBER_OF_VARIABLES<NUMBER_OF_VARIABLES) THEN
                  FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(1:FIELD%NUMBER_OF_VARIABLES)= &
                    & OLD_VARIABLE_TYPES(1:FIELD%NUMBER_OF_VARIABLES)
                  FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(:,1:FIELD%NUMBER_OF_VARIABLES)= &
                    & OLD_INTERPOLATION_TYPE(:,1:FIELD%NUMBER_OF_VARIABLES)
                  FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(:,1:FIELD%NUMBER_OF_VARIABLES)= &
                    & OLD_MESH_COMPONENT_NUMBER(:,1:FIELD%NUMBER_OF_VARIABLES)
                  DO variable_idx=FIELD%NUMBER_OF_VARIABLES+1,NUMBER_OF_VARIABLES
                    FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(variable_idx)=variable_idx
                    FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(:,variable_idx)=OLD_INTERPOLATION_TYPE(:,1)
                    FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(:,variable_idx)=OLD_MESH_COMPONENT_NUMBER(:,1)
                  ENDDO !variable_idx
                ELSE
                  FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(1:NUMBER_OF_VARIABLES)=OLD_VARIABLE_TYPES(1:NUMBER_OF_VARIABLES)
                  FIELD%CREATE_VALUES_CACHE%INTERPOLATION_TYPE(:,1:NUMBER_OF_VARIABLES)= &
                    & OLD_INTERPOLATION_TYPE(:,1:NUMBER_OF_VARIABLES)
                  FIELD%CREATE_VALUES_CACHE%MESH_COMPONENT_NUMBER(:,1:NUMBER_OF_VARIABLES)= &
                    & OLD_MESH_COMPONENT_NUMBER(:,1:NUMBER_OF_VARIABLES)
                ENDIF
                FIELD%NUMBER_OF_VARIABLES=NUMBER_OF_VARIABLES
                DEALLOCATE(OLD_VARIABLE_TYPES)
                DEALLOCATE(OLD_INTERPOLATION_TYPE)
                DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
              ENDIF
            ELSE
              LOCAL_ERROR="The number of variables ("//TRIM(NUMBER_TO_VSTRING(NUMBER_OF_VARIABLES,"*",ERR,ERROR))// &
                & ") is not valid. The number must be >0 and <=4"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          CASE DEFAULT
            LOCAL_ERROR="The field dependent type of "//TRIM(NUMBER_TO_VSTRING(FIELD%DEPENDENT_TYPE,"*",ERR,ERROR))// &
              & " is invalid"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Field create values cache is not associated",ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_NUMBER_OF_VARIABLES_SET_PTR")
    RETURN
999 IF(ALLOCATED(OLD_VARIABLE_TYPES)) DEALLOCATE(OLD_VARIABLE_TYPES)
    IF(ALLOCATED(OLD_INTERPOLATION_TYPE)) DEALLOCATE(OLD_INTERPOLATION_TYPE)
    IF(ALLOCATED(OLD_MESH_COMPONENT_NUMBER)) DEALLOCATE(OLD_MESH_COMPONENT_NUMBER)
    CALL ERRORS("FIELD_NUMBER_OF_VARIABLES_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_NUMBER_OF_VARIABLES_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_NUMBER_OF_VARIABLES_SET_PTR
  
  !
  !================================================================================================================================
  !

  !>Adds the parameter set from one parameter set type to another parameter set type
  SUBROUTINE FIELD_PARAMETER_SET_ADD(FIELD,FIELD_FROM_SET_TYPE,FIELD_TO_SET_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to add the parameter sets for
    INTEGER(INTG), INTENT(IN) :: FIELD_FROM_SET_TYPE !<The field parameter set identifier to add the parameters from
    INTEGER(INTG), INTENT(IN) :: FIELD_TO_SET_TYPE !<The field parameter set identifier to add the parameters to
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: dof,dof_idx
    REAL(DP) :: VALUE
    REAL(DP), POINTER :: FIELD_FROM_PARAMETERS(:)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: FIELD_DOMAIN_MAPPING
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: FIELD_FROM_PARAMETER_SET,FIELD_TO_PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR
   
    CALL ENTERS("FIELD_PARAMETER_SET_ADD",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        !Check the from set type input
        IF(FIELD_FROM_SET_TYPE>0.AND.FIELD_FROM_SET_TYPE<FIELD_NUMBER_OF_SET_TYPES) THEN
          FIELD_FROM_PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_FROM_SET_TYPE)%PTR
          IF(ASSOCIATED(FIELD_FROM_PARAMETER_SET)) THEN
            !Check the from set type input
            IF(FIELD_TO_SET_TYPE>0.AND.FIELD_TO_SET_TYPE<FIELD_NUMBER_OF_SET_TYPES) THEN
              FIELD_TO_PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_TO_SET_TYPE)%PTR
              !Loop over the non-ghosted dofs in the field
              IF(ASSOCIATED(FIELD_TO_PARAMETER_SET)) THEN
                FIELD_DOMAIN_MAPPING=>FIELD%MAPPINGS%DOMAIN_MAPPING
                IF(ASSOCIATED(FIELD_DOMAIN_MAPPING)) THEN
                  !Get the from parameter set data
                  CALL DISTRIBUTED_VECTOR_DATA_GET(FIELD_FROM_PARAMETER_SET%PARAMETERS,FIELD_FROM_PARAMETERS,ERR,ERROR,*999)
                  !Add the boundary field dofs
                  DO dof_idx=1,FIELD_DOMAIN_MAPPING%NUMBER_OF_BOUNDARY
                    dof=FIELD_DOMAIN_MAPPING%BOUNDARY_LIST(dof_idx)
                    VALUE=FIELD_FROM_PARAMETERS(dof)
                    CALL DISTRIBUTED_VECTOR_VALUES_ADD(FIELD_TO_PARAMETER_SET%PARAMETERS,dof,VALUE,ERR,ERROR,*999)
                  ENDDO !dof_idx
                  !Start the to parameter set transfer
                  CALL DISTRIBUTED_VECTOR_UPDATE_START(FIELD_TO_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)                  !
                  !Add the internal field dofs
                  DO dof_idx=1,FIELD_DOMAIN_MAPPING%NUMBER_OF_INTERNAL
                    dof=FIELD_DOMAIN_MAPPING%INTERNAL_LIST(dof_idx)
                    VALUE=FIELD_FROM_PARAMETERS(dof)
                    CALL DISTRIBUTED_VECTOR_VALUES_ADD(FIELD_TO_PARAMETER_SET%PARAMETERS,dof,VALUE,ERR,ERROR,*999)
                  ENDDO !dof_idx
                  !Finish the to parameter set transfer
                  CALL DISTRIBUTED_VECTOR_UPDATE_FINISH(FIELD_TO_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)
                  !Restore the from parameter set transfer
                  CALL DISTRIBUTED_VECTOR_DATA_RESTORE(FIELD_FROM_PARAMETER_SET%PARAMETERS,FIELD_FROM_PARAMETERS,ERR,ERROR,*999)
                 ELSE
                  CALL FLAG_ERROR("Field domain mapping is not associated.",ERR,ERROR,*999)
                ENDIF
              ELSE
                LOCAL_ERROR="The field to set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_TO_SET_TYPE,"*",ERR,ERROR))// &
                  & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//"."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="The field to set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_TO_SET_TYPE,"*",ERR,ERROR))// &
                & " is invalid. The field set type must be between 1 and "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))//"."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field from set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_FROM_SET_TYPE,"*",ERR,ERROR))// &
              & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//"."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field from set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_FROM_SET_TYPE,"*",ERR,ERROR))// &
            & " is invalid. The field set type must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))//"."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field has not been finished.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_ADD")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_ADD",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_ADD")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_ADD

  !
  !================================================================================================================================
  !

  !>Copys the parameter set from one parameter set type to another parameter set type
  SUBROUTINE FIELD_PARAMETER_SET_COPY(FIELD,FIELD_FROM_SET_TYPE,FIELD_TO_SET_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to copy the parameters set for
    INTEGER(INTG), INTENT(IN) :: FIELD_FROM_SET_TYPE !<The field parameter set identifier to copy the parameters from
    INTEGER(INTG), INTENT(IN) :: FIELD_TO_SET_TYPE !<The field parameter set identifier to copy the parameters to
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: dof,dof_idx
    REAL(DP) :: VALUE
    REAL(DP), POINTER :: FIELD_FROM_PARAMETERS(:)
    TYPE(DOMAIN_MAPPING_TYPE), POINTER :: FIELD_DOMAIN_MAPPING
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: FIELD_FROM_PARAMETER_SET,FIELD_TO_PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR
   
    CALL ENTERS("FIELD_PARAMETER_SET_COPY",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        !Check the from set type input
        IF(FIELD_FROM_SET_TYPE>0.AND.FIELD_FROM_SET_TYPE<FIELD_NUMBER_OF_SET_TYPES) THEN
          FIELD_FROM_PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_FROM_SET_TYPE)%PTR
          IF(ASSOCIATED(FIELD_FROM_PARAMETER_SET)) THEN
            !Check the from set type input
            IF(FIELD_TO_SET_TYPE>0.AND.FIELD_TO_SET_TYPE<FIELD_NUMBER_OF_SET_TYPES) THEN
              FIELD_TO_PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_TO_SET_TYPE)%PTR
              !Loop over the non-ghosted dofs in the field
              IF(ASSOCIATED(FIELD_TO_PARAMETER_SET)) THEN
                FIELD_DOMAIN_MAPPING=>FIELD%MAPPINGS%DOMAIN_MAPPING
                IF(ASSOCIATED(FIELD_DOMAIN_MAPPING)) THEN
                  !Get the from parameter set data
                  CALL DISTRIBUTED_VECTOR_DATA_GET(FIELD_FROM_PARAMETER_SET%PARAMETERS,FIELD_FROM_PARAMETERS,ERR,ERROR,*999)
                  !Set the boundary field dofs
                  DO dof_idx=1,FIELD_DOMAIN_MAPPING%NUMBER_OF_BOUNDARY
                    dof=FIELD_DOMAIN_MAPPING%BOUNDARY_LIST(dof_idx)
                    VALUE=FIELD_FROM_PARAMETERS(dof)
                    CALL DISTRIBUTED_VECTOR_VALUES_SET(FIELD_TO_PARAMETER_SET%PARAMETERS,dof,VALUE,ERR,ERROR,*999)
                  ENDDO !dof_idx
                  !Start the to parameter set transfer
                  CALL DISTRIBUTED_VECTOR_UPDATE_START(FIELD_TO_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)                  
                  !Set the internal field dofs
                  DO dof_idx=1,FIELD_DOMAIN_MAPPING%NUMBER_OF_INTERNAL
                    dof=FIELD_DOMAIN_MAPPING%INTERNAL_LIST(dof_idx)
                    VALUE=FIELD_FROM_PARAMETERS(dof)
                    CALL DISTRIBUTED_VECTOR_VALUES_SET(FIELD_TO_PARAMETER_SET%PARAMETERS,dof,VALUE,ERR,ERROR,*999)
                  ENDDO !dof_idx
                  !Finish the to parameter set transfer
                  CALL DISTRIBUTED_VECTOR_UPDATE_FINISH(FIELD_TO_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)
                  !Restore the from parameter set data
                  CALL DISTRIBUTED_VECTOR_DATA_RESTORE(FIELD_FROM_PARAMETER_SET%PARAMETERS,FIELD_FROM_PARAMETERS,ERR,ERROR,*999)
                 ELSE
                  CALL FLAG_ERROR("Field domain mapping is not associated.",ERR,ERROR,*999)
                ENDIF
              ELSE
                LOCAL_ERROR="The field to set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_TO_SET_TYPE,"*",ERR,ERROR))// &
                  & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//"."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="The field to set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_TO_SET_TYPE,"*",ERR,ERROR))// &
                & " is invalid. The field set type must be between 1 and "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))//"."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field from set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_FROM_SET_TYPE,"*",ERR,ERROR))// &
              & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//"."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field from set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_FROM_SET_TYPE,"*",ERR,ERROR))// &
            & " is invalid. The field set type must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))//"."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field has not been finished.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_COPY")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_COPY",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_COPY")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_COPY

  !
  !================================================================================================================================
  !

  !>Creates a new parameter set of type set type for a field.
  SUBROUTINE FIELD_PARAMETER_SET_CREATE(FIELD,FIELD_SET_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to create the parameter set for
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: DUMMY_ERR,parameter_set_idx
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: NEW_PARAMETER_SET
    TYPE(FIELD_PARAMETER_SET_PTR_TYPE), POINTER :: NEW_PARAMETER_SETS(:)
    TYPE(VARYING_STRING) :: LOCAL_ERROR,DUMMY_ERROR

    NULLIFY(NEW_PARAMETER_SET)
    NULLIFY(NEW_PARAMETER_SETS)
    
    CALL ENTERS("FIELD_PARAMETER_SET_CREATE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      !Check the set type input
      IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<FIELD_NUMBER_OF_SET_TYPES) THEN
        !Check if this set type has already been created
        IF(ASSOCIATED(FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR)) THEN
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " has already been created for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ELSE
          ALLOCATE(NEW_PARAMETER_SET,STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new parameter set",ERR,ERROR,*999)
          CALL FIELD_PARAMETER_SET_INITIALISE(NEW_PARAMETER_SET,ERR,ERROR,*999)
          NEW_PARAMETER_SET%SET_INDEX=FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS+1
          NEW_PARAMETER_SET%SET_TYPE=FIELD_SET_TYPE
          NULLIFY(NEW_PARAMETER_SET%PARAMETERS)
          CALL DISTRIBUTED_VECTOR_CREATE_START(FIELD%MAPPINGS%DOMAIN_MAPPING,NEW_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)
          CALL DISTRIBUTED_VECTOR_DATA_TYPE_SET(NEW_PARAMETER_SET%PARAMETERS,MATRIX_VECTOR_DP_TYPE,ERR,ERROR,*999)
          CALL DISTRIBUTED_VECTOR_CREATE_FINISH(NEW_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)                    
          CALL DISTRIBUTED_VECTOR_ALL_VALUES_SET(NEW_PARAMETER_SET%PARAMETERS,0.0_DP,ERR,ERROR,*999)
          !Add the new parameter set to the list of parameter sets
          ALLOCATE(NEW_PARAMETER_SETS(FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS+1),STAT=ERR)
          IF(ASSOCIATED(FIELD%PARAMETER_SETS%PARAMETER_SETS)) THEN
            DO parameter_set_idx=1,FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS
              NEW_PARAMETER_SETS(parameter_set_idx)%PTR=>FIELD%PARAMETER_SETS%PARAMETER_SETS(parameter_set_idx)%PTR
            ENDDO !parameter_set_idx
            DEALLOCATE(FIELD%PARAMETER_SETS%PARAMETER_SETS)
          ENDIF
          NEW_PARAMETER_SETS(FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS+1)%PTR=>NEW_PARAMETER_SET
          FIELD%PARAMETER_SETS%PARAMETER_SETS=>NEW_PARAMETER_SETS
          FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS=FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS+1
          FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR=>NEW_PARAMETER_SET
        ENDIF
      ELSE
        LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
          & " is invalid. The field set type must be between 1 and "// &
          & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_CREATE")
    RETURN
999 IF(ASSOCIATED(NEW_PARAMETER_SET)) THEN
      CALL FIELD_PARAMETER_SET_FINALISE(NEW_PARAMETER_SET,DUMMY_ERR,DUMMY_ERROR,*998)
998   DEALLOCATE(NEW_PARAMETER_SET)
    ENDIF
    IF(ASSOCIATED(NEW_PARAMETER_SETS)) DEALLOCATE(NEW_PARAMETER_SETS)
    CALL ERRORS("FIELD_PARAMETER_SET_CREATE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_CREATE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_CREATE

  !
  !================================================================================================================================
  !

  !>Destroys the parameter set of type set type for a field and deallocates all memory.
  SUBROUTINE FIELD_PARAMETER_SET_DESTROY(FIELD,FIELD_SET_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to destroy a parameter set for
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: parameter_set_idx,SET_INDEX
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(FIELD_PARAMETER_SET_PTR_TYPE), POINTER :: NEW_PARAMETER_SETS(:)
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    NULLIFY(NEW_PARAMETER_SETS)

    CALL ENTERS("FIELD_PARAMETER_SET_DESTROY",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      !Check the set type input
      IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<FIELD_NUMBER_OF_SET_TYPES) THEN
        !Check if the set type has been created
        PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
        IF(ASSOCIATED(PARAMETER_SET)) THEN
          SET_INDEX=PARAMETER_SET%SET_INDEX
          ALLOCATE(NEW_PARAMETER_SETS(FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS-1),STAT=ERR)
          IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new parameter sets",ERR,ERROR,*999)
          DO parameter_set_idx=1,FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS
            IF(parameter_set_idx<SET_INDEX) THEN
              NEW_PARAMETER_SETS(parameter_set_idx)%PTR=>FIELD%PARAMETER_SETS%PARAMETER_SETS(parameter_set_idx)%PTR              
            ELSE IF(parameter_set_idx>SET_INDEX) THEN
              NEW_PARAMETER_SETS(parameter_set_idx-1)%PTR=>FIELD%PARAMETER_SETS%PARAMETER_SETS(parameter_set_idx)%PTR
              NEW_PARAMETER_SETS(parameter_set_idx-1)%PTR%SET_INDEX=NEW_PARAMETER_SETS(parameter_set_idx-1)%PTR%SET_INDEX-1
            ENDIF
          ENDDO !parameter_set_idx
          DEALLOCATE(FIELD%PARAMETER_SETS%PARAMETER_SETS)
          FIELD%PARAMETER_SETS%PARAMETER_SETS=>NEW_PARAMETER_SETS
          FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS=FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS-1
          NULLIFY(FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR)
          CALL FIELD_PARAMETER_SET_FINALISE(PARAMETER_SET,ERR,ERROR,*999)
          DEALLOCATE(PARAMETER_SET)
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " has not been created for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
          & " is invalid. The field set type must be between 1 and "// &
          & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_DESTROY")
    RETURN
999 IF(ASSOCIATED(NEW_PARAMETER_SETS)) DEALLOCATE(NEW_PARAMETER_SETS)
    CALL ERRORS("FIELD_PARAMETER_SET_DESTROY",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_DESTROY")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_DESTROY

  !
  !================================================================================================================================
  !

  !>Finalises the parameter set for a field and deallocates all memory.
  SUBROUTINE FIELD_PARAMETER_SET_FINALISE(FIELD_PARAMETER_SET,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: FIELD_PARAMETER_SET !<A pointer to the field parameter set to destroy
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_PARAMETER_SET_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD_PARAMETER_SET)) THEN
      CALL DISTRIBUTED_VECTOR_DESTROY(FIELD_PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)
    ELSE
      CALL FLAG_ERROR("Field parameter set is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_FINALISE

  !
  !================================================================================================================================
  !

  !>Returns a pointer to the specified field parameter set array. The pointer must be restored with a call to FIELD_PARAMETER_SET_RESTORE call. Note: the values can be used for read operations but a FIELD_PARAMETER_SET_UPDATE call must be used to change any values.
  SUBROUTINE FIELD_PARAMETER_SET_GET(FIELD,FIELD_SET_TYPE,PARAMETERS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to get the parameter set from
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    REAL(DP), POINTER :: PARAMETERS(:) !<On exit, a pointer to the field parameter set data
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FIELD_PARAMETER_SET_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(PARAMETERS)) THEN
        CALL FLAG_ERROR("Parameters is already associated",ERR,ERROR,*999)
      ELSE
        NULLIFY(PARAMETERS)
        IF(FIELD%FIELD_FINISHED) THEN
          IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
            PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
            IF(ASSOCIATED(PARAMETER_SET)) THEN
              CALL DISTRIBUTED_VECTOR_DATA_GET(PARAMETER_SET%PARAMETERS,PARAMETERS,ERR,ERROR,*999)
            ELSE
              LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
                & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
              & " is invalid. The field set type must be between 1 and "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
            & " has not been finished"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_GET")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_GET",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_GET")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_GET

  !
  !================================================================================================================================
  !

  !>Initialises the parameter set for a field.
  SUBROUTINE FIELD_PARAMETER_SET_INITIALISE(FIELD_PARAMETER_SET,ERR,ERROR,*)

   !Argument variables
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: FIELD_PARAMETER_SET !<The field parameter set to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_PARAMETER_SET_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD_PARAMETER_SET)) THEN
      FIELD_PARAMETER_SET%SET_INDEX=0
      FIELD_PARAMETER_SET%SET_TYPE=0
    ELSE
      CALL FLAG_ERROR("Field parameter set is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_INITIALISE

  !
  !================================================================================================================================
  !

  !>Restores the specified field parameter set array that was obtained with FIELD_PARAMETER_SET_GET.
  SUBROUTINE FIELD_PARAMETER_SET_RESTORE(FIELD,FIELD_SET_TYPE,PARAMETERS,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to restore the parameter set from
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    REAL(DP), POINTER :: PARAMETERS(:) !<The pointer to the field parameter set data obtained with the parameter set get call
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("FIELD_PARAMETER_SET_RESTORE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(ASSOCIATED(PARAMETERS)) THEN
          IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
            PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
            IF(ASSOCIATED(PARAMETER_SET)) THEN
              CALL DISTRIBUTED_VECTOR_DATA_RESTORE(PARAMETER_SET%PARAMETERS,PARAMETERS,ERR,ERROR,*999)
            ELSE
              LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
                & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
              & " is invalid. The field set type must be between 1 and "// &
              & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Parameters is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_RESTORE")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_RESTORE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_RESTORE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_RESTORE

  !
  !================================================================================================================================
  !

  !>Updates the given parameter set with the given value for the constant of the field variable component.
  SUBROUTINE FIELD_PARAMETER_SET_UPDATE_CONSTANT(FIELD,FIELD_SET_TYPE,COMPONENT_NUMBER,VARIABLE_NUMBER,VALUE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to update
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    INTEGER(INTG), INTENT(IN) :: COMPONENT_NUMBER !<The field variable component number to update
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The field variable to update
    REAL(DP), INTENT(IN) :: VALUE !<The value to update to
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: ny
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_PARAMETER_SET_UPDATE_CONSTANT",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
          PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
          IF(ASSOCIATED(PARAMETER_SET)) THEN
            IF(VARIABLE_NUMBER>0.AND.VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
              IF(COMPONENT_NUMBER>=1.AND.COMPONENT_NUMBER<=FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS) THEN
                IF(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%PARAM_TO_DOF_MAP% &
                  & NUMBER_OF_CONSTANT_PARAMETERS>0) THEN
                  ny=FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%PARAM_TO_DOF_MAP%CONSTANT_PARAM2DOF_MAP(0)
                  CALL DISTRIBUTED_VECTOR_VALUES_SET(PARAMETER_SET%PARAMETERS,ny,VALUE,ERR,ERROR,*999)
                ELSE
                  LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " does not have any constant parameters."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
                
              ELSE
                LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                  & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                  & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                  & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
                  & " components"
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
              & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " is invalid. The field set type must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_CONSTANT")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_UPDATE_CONSTANT",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_CONSTANT")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_UPDATE_CONSTANT

  !
  !================================================================================================================================
  !

  !>Updates the given parameter set with the given value for a particular dof of the field.
  SUBROUTINE FIELD_PARAMETER_SET_UPDATE_DOF(FIELD,FIELD_SET_TYPE,DOF_NUMBER,VALUE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to update
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    INTEGER(INTG), INTENT(IN) :: DOF_NUMBER !<The dof number to update
    REAL(DP), INTENT(IN) :: VALUE !<The value to update to
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: GLOBAL_DOF_NUMBER
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_PARAMETER_SET_UPDATE_DOF",ERR,ERROR,*999)

!!TODO: Allow multiple dof number and values updates.    
    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
          PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
          IF(ASSOCIATED(PARAMETER_SET)) THEN
!!TODO: Allow to specify a global number and then have it all update accordingly???
            !Note that dofs are slightly different from other mappings in that all the local dofs are not all at the start. This
            !is because the dof indicies are from combined field components. Thus need to check that a ghost value is not being
            !set.
            IF(DOF_NUMBER>0.AND.DOF_NUMBER<=FIELD%MAPPINGS%DOMAIN_MAPPING%TOTAL_NUMBER_OF_LOCAL) THEN
              GLOBAL_DOF_NUMBER=FIELD%MAPPINGS%DOMAIN_MAPPING%LOCAL_TO_GLOBAL_MAP(DOF_NUMBER)
              IF(FIELD%MAPPINGS%DOMAIN_MAPPING%GLOBAL_TO_LOCAL_MAP(GLOBAL_DOF_NUMBER)%LOCAL_TYPE(1)/=DOMAIN_LOCAL_GHOST) THEN
                CALL DISTRIBUTED_VECTOR_VALUES_SET(PARAMETER_SET%PARAMETERS,DOF_NUMBER,VALUE,ERR,ERROR,*999)
              ELSE
                LOCAL_ERROR="The field dof number of "//TRIM(NUMBER_TO_VSTRING(DOF_NUMBER,"*",ERR,ERROR))// &
                  & " is invalid as it is a ghost dof for this domain"
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="The field dof number of "//TRIM(NUMBER_TO_VSTRING(DOF_NUMBER,"*",ERR,ERROR))// &
                & " is invalid. It must be >0 and <="// &
                & TRIM(NUMBER_TO_VSTRING(FIELD%MAPPINGS%DOMAIN_MAPPING%TOTAL_NUMBER_OF_LOCAL,"*",ERR,ERROR))// &
                & " for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
              & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " is invalid. The field set type must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_DOF")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_UPDATE_DOF",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_DOF")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_UPDATE_DOF

  !
  !================================================================================================================================
  !

  !>Updates the given parameter set with the given value for a particular element of the field variable component.
  SUBROUTINE FIELD_PARAMETER_SET_UPDATE_ELEMENT(FIELD,FIELD_SET_TYPE,ELEMENT_NUMBER,COMPONENT_NUMBER,VARIABLE_NUMBER, &
    & VALUE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to update
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to update
    INTEGER(INTG), INTENT(IN) :: COMPONENT_NUMBER !<The field variable component to update
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The field variable to update
    REAL(DP), INTENT(IN) :: VALUE !<The value to update to
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: ny
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_PARAMETER_SET_UPDATE_ELEMENT",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
          PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
          IF(ASSOCIATED(PARAMETER_SET)) THEN
            IF(VARIABLE_NUMBER>0.AND.VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
              IF(COMPONENT_NUMBER>=1.AND.COMPONENT_NUMBER<=FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS) THEN
                IF(ELEMENT_NUMBER>0.AND.ELEMENT_NUMBER<FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                  & PARAM_TO_DOF_MAP%NUMBER_OF_ELEMENT_PARAMETERS) THEN
                  ny=FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%PARAM_TO_DOF_MAP% &
                    & ELEMENT_PARAM2DOF_MAP(ELEMENT_NUMBER,0)
                  CALL DISTRIBUTED_VECTOR_VALUES_SET(PARAMETER_SET%PARAMETERS,ny,VALUE,ERR,ERROR,*999)
                ELSE
                  LOCAL_ERROR="Element number "//TRIM(NUMBER_TO_VSTRING(ELEMENT_NUMBER,"*",ERR,ERROR))// &
                    & " is invalid for component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " which has "//TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                    & PARAM_TO_DOF_MAP%NUMBER_OF_ELEMENT_PARAMETERS,"*",ERR,ERROR))//" elements."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
              ELSE
                LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                  & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                  & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                  & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
                  & " components"
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
              & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " is invalid. The field set type must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_ELEMENT")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_UPDATE_ELEMENT",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_ELEMENT")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_UPDATE_ELEMENT

  !
  !================================================================================================================================
  !

  !>Finishes the the parameter set update for a field. 
  SUBROUTINE FIELD_PARAMETER_SET_UPDATE_FINISH(FIELD,FIELD_SET_TYPE,ERR,ERROR,*)

     !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finish the update for
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier to finish the update for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_PARAMETER_SET_UPDATE_FINISH",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
        PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
        IF(ASSOCIATED(PARAMETER_SET)) THEN
          CALL DISTRIBUTED_VECTOR_UPDATE_FINISH(PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)
          IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE.AND.FIELD_SET_TYPE==FIELD_VALUES_SET_TYPE) THEN
            !Geometric field values have changed so update the geometric parmeters (e.g., lines)
            CALL FIELD_GEOMETRIC_PARAMETERS_CALCULATE(FIELD,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
          & " is invalid. The field set type must be between 1 and "// &
          & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_FINISH")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_UPDATE_FINISH",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_FINISH")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_UPDATE_FINISH

  !
  !================================================================================================================================
  !

  !>Updates the given parameter set with the given value for a particular node and derivative of the field variable component.
  SUBROUTINE FIELD_PARAMETER_SET_UPDATE_NODE(FIELD,FIELD_SET_TYPE,DERIVATIVE_NUMBER,NODE_NUMBER,COMPONENT_NUMBER,VARIABLE_NUMBER, &
    & VALUE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to update
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier
    INTEGER(INTG), INTENT(IN) :: DERIVATIVE_NUMBER !<The node derivative number to update
    INTEGER(INTG), INTENT(IN) :: NODE_NUMBER !<The node number to update
    INTEGER(INTG), INTENT(IN) :: COMPONENT_NUMBER !<The field variable component number to update
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The field variable to update
    REAL(DP), INTENT(IN) :: VALUE !<The value to update to
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: ny
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_PARAMETER_SET_UPDATE_NODE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
          PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
          IF(ASSOCIATED(PARAMETER_SET)) THEN
            IF(VARIABLE_NUMBER>0.AND.VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
              IF(COMPONENT_NUMBER>=1.AND.COMPONENT_NUMBER<=FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS) THEN
                IF(NODE_NUMBER>0.AND.NODE_NUMBER<=FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                  & PARAM_TO_DOF_MAP%NUMBER_OF_NODE_PARAMETERS) THEN
                  IF(DERIVATIVE_NUMBER>0.AND.DERIVATIVE_NUMBER<=FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                    & PARAM_TO_DOF_MAP%MAX_NUMBER_OF_DERIVATIVES) THEN
                    ny=FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)%PARAM_TO_DOF_MAP% &
                      & NODE_PARAM2DOF_MAP(DERIVATIVE_NUMBER,NODE_NUMBER,0)
                    CALL DISTRIBUTED_VECTOR_VALUES_SET(PARAMETER_SET%PARAMETERS,ny,VALUE,ERR,ERROR,*999)
                  ELSE
                    LOCAL_ERROR="Derivative number "//TRIM(NUMBER_TO_VSTRING(DERIVATIVE_NUMBER,"*",ERR,ERROR))// &
                    & " is invalid for node number "//TRIM(NUMBER_TO_VSTRING(NODE_NUMBER,"*",ERR,ERROR))// &
                    & " of component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " which has a maximum of "// &
                    & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                    & PARAM_TO_DOF_MAP%MAX_NUMBER_OF_DERIVATIVES,"*",ERR,ERROR))//" derivatives."
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  ENDIF
                ELSE
                  LOCAL_ERROR="Node number "//TRIM(NUMBER_TO_VSTRING(NODE_NUMBER,"*",ERR,ERROR))// &
                    & " is invalid for component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                    & " of variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                    & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
                    & " which has "//TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(COMPONENT_NUMBER)% &
                    & PARAM_TO_DOF_MAP%NUMBER_OF_NODE_PARAMETERS,"*",ERR,ERROR))//" nodes."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                ENDIF
              ELSE
                LOCAL_ERROR="Component number "//TRIM(NUMBER_TO_VSTRING(COMPONENT_NUMBER,"*",ERR,ERROR))// &
                  & " is invalid for variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                  & " of field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                  & TRIM(NUMBER_TO_VSTRING(FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))// &
                  & " components"
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              ENDIF
            ELSE
              LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
                & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
                & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            ENDIF
          ELSE
            LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
              & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
            & " is invalid. The field set type must be between 1 and "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="Field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " has not been finished"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_NODE")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_UPDATE_NODE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_NODE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_UPDATE_NODE

  !
  !================================================================================================================================
  !

  !>Starts the the parameter set update for a field. 
  SUBROUTINE FIELD_PARAMETER_SET_UPDATE_START(FIELD,FIELD_SET_TYPE,ERR,ERROR,*)

    !Argument variables 
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to start the update for
    INTEGER(INTG), INTENT(IN) :: FIELD_SET_TYPE !<The field parameter set identifier to update
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_PARAMETER_SET_TYPE), POINTER :: PARAMETER_SET
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_PARAMETER_SET_UPDATE_START",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD_SET_TYPE>0.AND.FIELD_SET_TYPE<=FIELD_NUMBER_OF_SET_TYPES) THEN
        PARAMETER_SET=>FIELD%PARAMETER_SETS%SET_TYPE(FIELD_SET_TYPE)%PTR
        IF(ASSOCIATED(PARAMETER_SET)) THEN
          CALL DISTRIBUTED_VECTOR_UPDATE_START(PARAMETER_SET%PARAMETERS,ERR,ERROR,*999)
        ELSE
          LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
          & " has not been created on field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The field set type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SET_TYPE,"*",ERR,ERROR))// &
          & " is invalid. The field set type must be between 1 and "// &
          & TRIM(NUMBER_TO_VSTRING(FIELD_NUMBER_OF_SET_TYPES,"*",ERR,ERROR))
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_START")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SET_UPDATE_START",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SET_UPDATE_START")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SET_UPDATE_START

  !
  !================================================================================================================================
  !

  !>Finalises the parameter sets for a field and deallocates all memory. 
  SUBROUTINE FIELD_PARAMETER_SETS_FINALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finalise the parameter sets for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: parameter_set_idx

    CALL ENTERS("FIELD_PARAMETER_SETS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%PARAMETER_SETS%SET_TYPE)) DEALLOCATE(FIELD%PARAMETER_SETS%SET_TYPE)
      IF(ASSOCIATED(FIELD%PARAMETER_SETS%PARAMETER_SETS)) THEN        
        DO parameter_set_idx=1,FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS
          CALL FIELD_PARAMETER_SET_FINALISE(FIELD%PARAMETER_SETS%PARAMETER_SETS(parameter_set_idx)%PTR,ERR,ERROR,*999)
        ENDDO !parameter_set_idx
        DEALLOCATE(FIELD%PARAMETER_SETS%PARAMETER_SETS)
      ENDIF
      FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS=0
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SETS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SETS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SETS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SETS_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the parameter sets for a field. 
  SUBROUTINE FIELD_PARAMETER_SETS_INITIALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the parameter sets for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR
    !Local Variables
    INTEGER(INTG) :: parameter_set_idx

    CALL ENTERS("FIELD_PARAMETER_SETS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD%PARAMETER_SETS%FIELD=>FIELD
      FIELD%PARAMETER_SETS%NUMBER_OF_PARAMETER_SETS=0
      NULLIFY(FIELD%PARAMETER_SETS%PARAMETER_SETS)
      ALLOCATE(FIELD%PARAMETER_SETS%SET_TYPE(FIELD_NUMBER_OF_SET_TYPES),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field parameter sets set types",ERR,ERROR,*999)
      DO parameter_set_idx=1,FIELD_NUMBER_OF_SET_TYPES
        NULLIFY(FIELD%PARAMETER_SETS%SET_TYPE(parameter_set_idx)%PTR)
      ENDDO !parameter_set_idx      
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_PARAMETER_SETS_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_PARAMETER_SETS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_PARAMETER_SETS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_PARAMETER_SETS_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finalises the scaling for a field scaling index and deallocates all memory. 
  SUBROUTINE FIELD_SCALING_FINALISE(FIELD,SCALING_INDEX,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finalise the scalings for
    INTEGER(INTG), INTENT(IN) :: SCALING_INDEX !<The scaling index to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_SCALING_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(SCALING_INDEX>0.AND.SCALING_INDEX<=FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES) THEN
        !IF(ALLOCATED(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS))  &
        !  & DEALLOCATE(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS)
        CALL DISTRIBUTED_VECTOR_DESTROY(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS,ERR,ERROR,*999)
      ELSE
        LOCAL_ERROR="The scaling index of "//TRIM(NUMBER_TO_VSTRING(SCALING_INDEX,"*",ERR,ERROR))// &
          & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " which has "//TRIM(NUMBER_TO_VSTRING(FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES,"*",ERR,ERROR))// &
          & " scaling indices"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALING_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_SCALING_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_SCALING_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_SCALING_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the scalings for a field scaling index corresponding to a mesh component index.
  SUBROUTINE FIELD_SCALING_INITIALISE(FIELD,SCALING_INDEX,MESH_COMPONENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the scaling for
    INTEGER(INTG), INTENT(IN) :: SCALING_INDEX !<The scaling index to initialise
    INTEGER(INTG), INTENT(IN) :: MESH_COMPONENT_NUMBER !<The mesh component number to initialise for the scaling
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_SCALING_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(SCALING_INDEX>0.AND.SCALING_INDEX<=FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES) THEN
        IF(MESH_COMPONENT_NUMBER>0.AND.MESH_COMPONENT_NUMBER<=FIELD%DECOMPOSITION%MESH%NUMBER_OF_COMPONENTS) THEN
          FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%MESH_COMPONENT_NUMBER=MESH_COMPONENT_NUMBER
          FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%MAX_NUMBER_OF_ELEMENT_PARAMETERS=FIELD%DECOMPOSITION% &
            & DOMAIN(MESH_COMPONENT_NUMBER)%PTR%TOPOLOGY%ELEMENTS%MAXIMUM_NUMBER_OF_ELEMENT_PARAMETERS
          FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%MAX_NUMBER_OF_DERIVATIVES=FIELD%DECOMPOSITION% &
            & DOMAIN(MESH_COMPONENT_NUMBER)%PTR%TOPOLOGY%NODES%MAXIMUM_NUMBER_OF_DERIVATIVES
          NULLIFY(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS)
          SELECT CASE(FIELD%SCALINGS%SCALING_TYPE)
          CASE(FIELD_NO_SCALING)
            !Do nothing
          CASE(FIELD_UNIT_SCALING,FIELD_ARITHMETIC_MEAN_SCALING,FIELD_HARMONIC_MEAN_SCALING)
            !ALLOCATE(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)% &
            !  & MAX_NUMBER_OF_DERIVATIVES,FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR%TOPOLOGY% &
            !  & NODES%TOTAL_NUMBER_OF_NODES),STAT=ERR)
            !IF(ERR/=0) CALL FLAG_ERROR("Could not allocate scale factors",ERR,ERROR,*999)
            !FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS=1.0_DP
            CALL DISTRIBUTED_VECTOR_CREATE_START(FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR%MAPPINGS%DOFS, &
              & FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS,ERR,ERROR,*999)
            CALL DISTRIBUTED_VECTOR_DATA_TYPE_SET(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS,MATRIX_VECTOR_DP_TYPE, &
              & ERR,ERROR,*999)
            CALL DISTRIBUTED_VECTOR_CREATE_FINISH(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS,ERR,ERROR,*999)
            IF(FIELD%TYPE==FIELD_GEOMETRIC_TYPE) THEN
              !Initialise the scalings to 1.0 for a geometric field. Other field types will be setup in FIELD_SCALINGS_CALCULATE
              CALL DISTRIBUTED_VECTOR_ALL_VALUES_SET(FIELD%SCALINGS%SCALINGS(SCALING_INDEX)%SCALE_FACTORS,1.0_DP,ERR,ERROR,*999)
            ENDIF
          CASE(FIELD_ARC_LENGTH_SCALING)
            CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
          CASE DEFAULT
            LOCAL_ERROR="The scaling type of "//TRIM(NUMBER_TO_VSTRING(FIELD%SCALINGS%SCALING_TYPE,"*",ERR,ERROR))// &
              & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          LOCAL_ERROR="The mesh component number of "//TRIM(NUMBER_TO_VSTRING(SCALING_INDEX,"*",ERR,ERROR))// &
            & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
            & " which is associated with a mesh which has "//TRIM(NUMBER_TO_VSTRING(FIELD%DECOMPOSITION% &
            & MESH%NUMBER_OF_COMPONENTS,"*",ERR,ERROR))//" mesh components"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        LOCAL_ERROR="The scaling index of "//TRIM(NUMBER_TO_VSTRING(SCALING_INDEX,"*",ERR,ERROR))// &
          & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))// &
          & " which has "//TRIM(NUMBER_TO_VSTRING(FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES,"*",ERR,ERROR))// &
          & " scaling indices"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALING_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_SCALING_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_SCALING_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_SCALING_INITIALISE

  !
  !================================================================================================================================
  !
  
  !>Calculates the scale factors from the geometric field associated with the field.
  SUBROUTINE FIELD_SCALINGS_CALCULATE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to calculate the scalings for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: MESH_COMPONENT_NUMBER,ni,ni1,ni2,nk,nk2,nl,nl2,nlp,np,nu,nu1,nu2,ny,ny1,ny2,ny3,scaling_idx
    REAL(DP) :: LENGTH1,LENGTH2,MEAN_LENGTH,TEMP
    REAL(DP), POINTER :: SCALE_FACTORS(:)
    LOGICAL :: FOUND
    TYPE(DECOMPOSITION_LINES_TYPE), POINTER :: DECOMPOSITION_LINES
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_LINES_TYPE), POINTER :: DOMAIN_LINES
    TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD
    TYPE(FIELD_SCALING_TYPE), POINTER :: FIELD_SCALING
    TYPE(FIELD_SCALINGS_TYPE), POINTER :: FIELD_SCALINGS
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_SCALINGS_CALCULATE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_SCALINGS=>FIELD%SCALINGS
      IF(ASSOCIATED(FIELD_SCALINGS)) THEN
        GEOMETRIC_FIELD=>FIELD%GEOMETRIC_FIELD
        IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN
          SELECT CASE(FIELD_SCALINGS%SCALING_TYPE)
          CASE(FIELD_NO_SCALING)
            !Do nothing
          CASE(FIELD_UNIT_SCALING)
            DO scaling_idx=1,FIELD_SCALINGS%NUMBER_OF_SCALING_INDICES
              FIELD_SCALING=>FIELD_SCALINGS%SCALINGS(scaling_idx)
              MESH_COMPONENT_NUMBER=FIELD_SCALING%MESH_COMPONENT_NUMBER
              DOMAIN=>FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR
              CALL DISTRIBUTED_VECTOR_ALL_VALUES_SET(FIELD_SCALING%SCALE_FACTORS,1.0_DP,ERR,ERROR,*999)
              CALL DISTRIBUTED_VECTOR_UPDATE_START(FIELD_SCALING%SCALE_FACTORS,ERR,ERROR,*999)
              CALL DISTRIBUTED_VECTOR_UPDATE_FINISH(FIELD_SCALING%SCALE_FACTORS,ERR,ERROR,*999)
            ENDDO !scaling_idx            
          CASE(FIELD_ARC_LENGTH_SCALING)
            CALL FLAG_ERROR("Not implemented",ERR,ERROR,*999)
          CASE(FIELD_ARITHMETIC_MEAN_SCALING,FIELD_HARMONIC_MEAN_SCALING)
            DO scaling_idx=1,FIELD_SCALINGS%NUMBER_OF_SCALING_INDICES
              FIELD_SCALING=>FIELD_SCALINGS%SCALINGS(scaling_idx)
              MESH_COMPONENT_NUMBER=FIELD_SCALING%MESH_COMPONENT_NUMBER
              DOMAIN=>FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT_NUMBER)%PTR
              DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
              DOMAIN_LINES=>DOMAIN%TOPOLOGY%LINES
              DECOMPOSITION_LINES=>FIELD%DECOMPOSITION%TOPOLOGY%LINES
              NULLIFY(SCALE_FACTORS)
              CALL DISTRIBUTED_VECTOR_DATA_GET(FIELD_SCALING%SCALE_FACTORS,SCALE_FACTORS,ERR,ERROR,*999)                
              DO np=1,DOMAIN_NODES%NUMBER_OF_NODES
                DO nk=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_DERIVATIVES
                  ny=DOMAIN_NODES%NODES(np)%DOF_INDEX(nk)
                  nu=DOMAIN_NODES%NODES(np)%PARTIAL_DERIVATIVE_INDEX(nk)
                  SELECT CASE(nu)
                  CASE(NO_PART_DERIV)
                    CALL DISTRIBUTED_VECTOR_VALUES_SET(FIELD_SCALING%SCALE_FACTORS,ny,1.0_DP,ERR,ERROR,*999)
                  CASE(PART_DERIV_S1,PART_DERIV_S2,PART_DERIV_S3)
                    IF(nu==PART_DERIV_S1) THEN
                      ni=1
                    ELSE IF(nu==PART_DERIV_S2) THEN
                      ni=2
                    ELSE
                      ni=3
                    ENDIF
                    !Find a line of the correct Xi direction going through this node
                    FOUND=.FALSE.
                    DO nlp=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_NODE_LINES
                      nl=DOMAIN_NODES%NODES(np)%NODE_LINES(nlp)
                      IF(DECOMPOSITION_LINES%LINES(nl)%XI_DIRECTION==ni) THEN
                        FOUND=.TRUE.
                        EXIT
                      ENDIF
                    ENDDO !nnl
                    IF(FOUND) THEN
                      IF(DOMAIN_LINES%LINES(nl)%NODES_IN_LINE(1)==np) THEN !Current node at the beginning of the line
                        nl2=DECOMPOSITION_LINES%LINES(nl)%ADJACENT_LINES(0)
                      ELSE !Current node at the end of the line
                        nl2=DECOMPOSITION_LINES%LINES(nl)%ADJACENT_LINES(1)
                      ENDIF
                      IF(nl2==0) THEN
                        LENGTH1=GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS(nl)
                        MEAN_LENGTH=LENGTH1
                      ELSE
                        LENGTH1=GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS(nl)
                        LENGTH2=GEOMETRIC_FIELD%GEOMETRIC_FIELD_PARAMETERS%LENGTHS(nl2)
                        SELECT CASE(FIELD_SCALINGS%SCALING_TYPE)
                        CASE(FIELD_ARITHMETIC_MEAN_SCALING)
                          MEAN_LENGTH=(LENGTH1+LENGTH2)/2.0_DP
                        CASE(FIELD_HARMONIC_MEAN_SCALING)
                          TEMP=LENGTH1*LENGTH2
                          IF(ABS(TEMP)>ZERO_TOLERANCE) THEN
                            MEAN_LENGTH=2.0_DP*TEMP/(LENGTH1+LENGTH2)
                          ELSE
                            MEAN_LENGTH=0.0_DP
                          ENDIF
                        CASE DEFAULT
                          LOCAL_ERROR="The scaling type of "// &
                            & TRIM(NUMBER_TO_VSTRING(FIELD_SCALINGS%SCALING_TYPE,"*",ERR,ERROR))//" is invalid"
                          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT
                      ENDIF
                      CALL DISTRIBUTED_VECTOR_VALUES_SET(FIELD_SCALING%SCALE_FACTORS,ny,MEAN_LENGTH,ERR,ERROR,*999)
                    ELSE
                      LOCAL_ERROR="Could not find a line in the Xi "//TRIM(NUMBER_TO_VSTRING(ni,"*",ERR,ERROR))// &
                        & " direction going through node number "//TRIM(NUMBER_TO_VSTRING(np,"*",ERR,ERROR))
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                    ENDIF
                  CASE(PART_DERIV_S1_S2,PART_DERIV_S1_S3,PART_DERIV_S2_S3,PART_DERIV_S1_S2_S3)
                    IF(nu==PART_DERIV_S1_S2) THEN
                      ni1=1
                      nu1=PART_DERIV_S1
                      ni2=2
                      nu2=PART_DERIV_S2
                    ELSE IF(nu==PART_DERIV_S1_S3) THEN
                      ni1=1
                      nu1=PART_DERIV_S1
                      ni2=3
                      nu2=PART_DERIV_S3
                    ELSE IF(nu==PART_DERIV_S1_S2) THEN
                      ni1=2
                      nu1=PART_DERIV_S2
                      ni2=3
                      nu2=PART_DERIV_S3
                    ELSE
                      ni1=1
                      nu1=PART_DERIV_S1
                      ni2=2
                      nu2=PART_DERIV_S2
                    ENDIF
!!TODO: Shouldn't have to search for the nk directions. Store them somewhere.
                    !Find the first direction nk
                    FOUND=.FALSE.
                    DO nk2=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_DERIVATIVES
                      IF(DOMAIN_NODES%NODES(np)%PARTIAL_DERIVATIVE_INDEX(nk2)==nu1) THEN
                        ny1=DOMAIN_NODES%NODES(np)%DOF_INDEX(nk2)
                        FOUND=.TRUE.
                        EXIT
                      ENDIF
                    ENDDO !nk2
                    IF(FOUND) THEN
                      !Find the second direction nk
                      FOUND=.FALSE.
                      DO nk2=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_DERIVATIVES
                        IF(DOMAIN_NODES%NODES(np)%PARTIAL_DERIVATIVE_INDEX(nk2)==nu2) THEN
                          ny2=DOMAIN_NODES%NODES(np)%DOF_INDEX(nk2)
                          FOUND=.TRUE.
                          EXIT
                        ENDIF
                      ENDDO !nk2
                      IF(FOUND) THEN
                        IF(nu==PART_DERIV_S1_S2_S3) THEN
                          !Find the third direction nk
                          FOUND=.FALSE.
                          DO nk2=1,DOMAIN_NODES%NODES(np)%NUMBER_OF_DERIVATIVES
                            IF(DOMAIN_NODES%NODES(np)%PARTIAL_DERIVATIVE_INDEX(nk2)==PART_DERIV_S3) THEN
                              ny3=DOMAIN_NODES%NODES(np)%DOF_INDEX(nk2)
                              FOUND=.TRUE.
                              EXIT
                            ENDIF
                          ENDDO !nk2
                          IF(FOUND) THEN                          
                            CALL DISTRIBUTED_VECTOR_VALUES_SET(FIELD_SCALING%SCALE_FACTORS,ny, &
                              SCALE_FACTORS(ny1)*SCALE_FACTORS(ny2)*SCALE_FACTORS(ny3),ERR,ERROR,*999)
                          ELSE
                            LOCAL_ERROR="Could not find the first partial derivative in the s3 direction index for "//&
                              & "local node number "//TRIM(NUMBER_TO_VSTRING(np,"*",ERR,ERROR))
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                          ENDIF
                        ELSE
                          CALL DISTRIBUTED_VECTOR_VALUES_SET(FIELD_SCALING%SCALE_FACTORS,ny,SCALE_FACTORS(ny1)* &
                            & SCALE_FACTORS(ny2),ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        LOCAL_ERROR="Could not find the first partial derivative in the s"// &
                          & TRIM(NUMBER_TO_VSTRING(ni2,"*",ERR,ERROR))//" direction index for "//&
                          & "local node number "//TRIM(NUMBER_TO_VSTRING(np,"*",ERR,ERROR))
                        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                      ENDIF
                    ELSE
                      LOCAL_ERROR="Could not find the first partial derivative in the s"// &
                        & TRIM(NUMBER_TO_VSTRING(ni1,"*",ERR,ERROR))//" direction index for "//&
                        & "local node number "//TRIM(NUMBER_TO_VSTRING(np,"*",ERR,ERROR))
                    ENDIF
                  CASE DEFAULT
                    LOCAL_ERROR="The partial derivative index of "//TRIM(NUMBER_TO_VSTRING(nu,"*",ERR,ERROR))// &
                      & " for derivative number "//TRIM(NUMBER_TO_VSTRING(nk,"*",ERR,ERROR))// &
                      & " of local node number "//TRIM(NUMBER_TO_VSTRING(np,"*",ERR,ERROR))//" is invalid"
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                ENDDO !nk
              ENDDO !np
              CALL DISTRIBUTED_VECTOR_UPDATE_START(FIELD_SCALING%SCALE_FACTORS,ERR,ERROR,*999)
              CALL DISTRIBUTED_VECTOR_UPDATE_FINISH(FIELD_SCALING%SCALE_FACTORS,ERR,ERROR,*999)
            ENDDO !scaling_idx
          CASE DEFAULT
            LOCAL_ERROR="The scaling type of "//TRIM(NUMBER_TO_VSTRING(FIELD_SCALINGS%SCALING_TYPE,"*",ERR,ERROR))// &
              & " is invalid"
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT        
        ELSE
          CALL FLAG_ERROR("Field geometric field is not associated",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field scalings is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALINGS_CALCULATE")
    RETURN
999 CALL ERRORS("FIELD_SCALINGS_CALCULATE",ERR,ERROR)
    CALL EXITS("FIELD_SCALINGS_CALCULATE")
    RETURN 1
  END SUBROUTINE FIELD_SCALINGS_CALCULATE

  !
  !================================================================================================================================
  !

  !>Finalises the scalings for a field and deallocates all memory. 
  SUBROUTINE FIELD_SCALINGS_FINALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finalise the scalings for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: scaling_idx

    CALL ENTERS("FIELD_SCALINGS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      DO scaling_idx=1,FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES
        CALL FIELD_SCALING_FINALISE(FIELD,scaling_idx,ERR,ERROR,*999)
      ENDDO !scaling_idx
      IF(ALLOCATED(FIELD%SCALINGS%SCALINGS)) DEALLOCATE(FIELD%SCALINGS%SCALINGS)
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALINGS_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_SCALINGS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_SCALINGS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_SCALINGS_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the scaling parameters sets for a field. 
  SUBROUTINE FIELD_SCALINGS_INITIALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the scalings for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,NUMBER_OF_MESH_COMPONENTS,scaling_idx,variable_idx
    INTEGER(INTG), ALLOCATABLE :: MESH_COMPONENTS_MAP(:)
    INTEGER(INTG), POINTER :: MESH_COMPONENTS(:)
    TYPE(LIST_TYPE), POINTER :: MESH_COMPONENTS_LIST

    NULLIFY(MESH_COMPONENTS)
    NULLIFY(MESH_COMPONENTS_LIST)

    CALL ENTERS("FIELD_SCALINGS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      !Calculate the mesh component numbers involved in the field
      CALL LIST_CREATE_START(MESH_COMPONENTS_LIST,ERR,ERROR,*999)
      CALL LIST_DATA_TYPE_SET(MESH_COMPONENTS_LIST,LIST_INTG_TYPE,ERR,ERROR,*999)
      CALL LIST_INITIAL_SIZE_SET(MESH_COMPONENTS_LIST,FIELD%DECOMPOSITION%MESH%NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
      CALL LIST_CREATE_FINISH(MESH_COMPONENTS_LIST,ERR,ERROR,*999)
      DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
        DO component_idx=1,FIELD%VARIABLES(variable_idx)%NUMBER_OF_COMPONENTS
          CALL LIST_ITEM_ADD(MESH_COMPONENTS_LIST,FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)%MESH_COMPONENT_NUMBER, &
            & ERR,ERROR,*999)
        ENDDO !component_idx
      ENDDO !variable_idx
      CALL LIST_REMOVE_DUPLICATES(MESH_COMPONENTS_LIST,ERR,ERROR,*999)
      CALL LIST_DETACH_AND_DESTROY(MESH_COMPONENTS_LIST,NUMBER_OF_MESH_COMPONENTS,MESH_COMPONENTS,ERR,ERROR,*999)
      ALLOCATE(MESH_COMPONENTS_MAP(FIELD%DECOMPOSITION%MESH%NUMBER_OF_COMPONENTS),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate mesh components map",ERR,ERROR,*999)
      MESH_COMPONENTS_MAP=0
      DO component_idx=1,NUMBER_OF_MESH_COMPONENTS
        MESH_COMPONENTS_MAP(MESH_COMPONENTS(component_idx))=component_idx
      ENDDO !component_idx
      !Allocate the scaling indices and initialise them
      FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES=NUMBER_OF_MESH_COMPONENTS
      ALLOCATE(FIELD%SCALINGS%SCALINGS(FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES),STAT=ERR)
      IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field scalings",ERR,ERROR,*999)
      DO scaling_idx=1,FIELD%SCALINGS%NUMBER_OF_SCALING_INDICES
        CALL FIELD_SCALING_INITIALISE(FIELD,scaling_idx,MESH_COMPONENTS(scaling_idx),ERR,ERROR,*999)
      ENDDO !scaling_idx
      !Set the scaling index for all the field variable components
      DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
        DO component_idx=1,FIELD%VARIABLES(variable_idx)%NUMBER_OF_COMPONENTS
          FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)%SCALING_INDEX= &
            & MESH_COMPONENTS_MAP(FIELD%VARIABLES(variable_idx)%COMPONENTS(component_idx)%MESH_COMPONENT_NUMBER)
        ENDDO !component_idx
      ENDDO !variable_idx
      DEALLOCATE(MESH_COMPONENTS)
      IF(FIELD%TYPE/=FIELD_GEOMETRIC_TYPE) CALL FIELD_SCALINGS_CALCULATE(FIELD,ERR,ERROR,*999)
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALINGS_INITIALISE")
    RETURN
999 IF(ASSOCIATED(MESH_COMPONENTS)) DEALLOCATE(MESH_COMPONENTS)
    IF(ASSOCIATED(MESH_COMPONENTS_LIST)) CALL LIST_DESTROY(MESH_COMPONENTS_LIST,ERR,ERROR,*999)
    CALL ERRORS("FIELD_SCALINGS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_SCALINGS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_SCALINGS_INITIALISE

  !
  !================================================================================================================================
  !

!!MERGE: Ditto
  
  !>Gets the scaling type for a field identified by a pointer.
  FUNCTION FIELD_SCALING_TYPE_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the scaling type for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_SCALING_TYPE_GET !<The scaling type to get \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
    !Local Variables

    CALL ENTERS("FIELD_SCALING_TYPE_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_SCALING_TYPE_GET=FIELD%SCALINGS%SCALING_TYPE
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALING_TYPE_GET")
    RETURN
999 CALL ERRORS("FIELD_SCALING_TYPE_GET",ERR,ERROR)
    CALL EXITS("FIELD_SCALING_TYPE_GET")
    RETURN
  END FUNCTION FIELD_SCALING_TYPE_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the scaling type for a field identified by a user number on a region.
  SUBROUTINE FIELD_SCALING_TYPE_SET_NUMBER(USER_NUMBER,REGION,SCALING_TYPE,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    INTEGER(INTG), INTENT(IN) :: SCALING_TYPE !<The scaling type to set \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_SCALING_TYPE_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.
    
    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_SCALING_TYPE_SET_PTR(FIELD,SCALING_TYPE,ERR,ERROR,*999)
       
    CALL EXITS("FIELD_SCALING_TYPE_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_SCALING_TYPE_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_SCALING_TYPE_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_SCALING_TYPE_SET_NUMBER

  !
  !================================================================================================================================
  !

  !>Sets/changes the scaling type for a field identified by a pointer.
  SUBROUTINE FIELD_SCALING_TYPE_SET_PTR(FIELD,SCALING_TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the scaling type for
    INTEGER(INTG), INTENT(IN) :: SCALING_TYPE !<The scaling type to set \see FIELD_ROUTINES_ScalingTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_SCALING_TYPE_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        SELECT CASE(SCALING_TYPE)
        CASE(FIELD_NO_SCALING,FIELD_UNIT_SCALING,FIELD_ARC_LENGTH_SCALING,FIELD_ARITHMETIC_MEAN_SCALING, &
          & FIELD_HARMONIC_MEAN_SCALING)
          FIELD%SCALINGS%SCALING_TYPE=SCALING_TYPE
        CASE DEFAULT
          LOCAL_ERROR="Scaling type "//TRIM(NUMBER_TO_VSTRING(SCALING_TYPE,"*",ERR,ERROR))// &
            & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_SCALING_TYPE_SET_PTR")
    RETURN
999 CALL ERRORS("FIELD_SCALING_TYPE_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_SCALING_TYPE_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_SCALING_TYPE_SET_PTR
  
  !
  !================================================================================================================================
  !

  !!MERGE: ditto
  
  !>Gets the field type for a field identified by a pointer.
  FUNCTION FIELD_TYPE_GET(FIELD,ERR,ERROR)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the type for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Function result
    INTEGER(INTG) :: FIELD_TYPE_GET !<The field type to get \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
    !Local Variables

    CALL ENTERS("FIELD_TYPE_GET",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      FIELD_TYPE_GET=FIELD%TYPE
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_TYPE_GET")
    RETURN
999 CALL ERRORS("FIELD_TYPE_GET",ERR,ERROR)
    CALL EXITS("FIELD_TYPE_GET")
    RETURN
  END FUNCTION FIELD_TYPE_GET
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the field type for a field identified by a user number.
  SUBROUTINE FIELD_TYPE_SET_NUMBER(USER_NUMBER,REGION,TYPE,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The user number of the field
    TYPE(REGION_TYPE), POINTER :: REGION !<The region containing the field
    INTEGER(INTG), INTENT(IN) :: TYPE !<The field type to set \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELD_TYPE_SET_NUMBER",ERR,ERROR,*999)

!!TODO: Take in region number here and user FIND_REGION_NUMBER. This would require FIND_REGION_NUMBER to be moved from
!!REGION_ROUTINES otherwise there will be a circular module reference.

    CALL FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*999)
    CALL FIELD_TYPE_SET(FIELD,TYPE,ERR,ERROR,*999)
           
    CALL EXITS("FIELD_TYPE_SET_NUMBER")
    RETURN
999 CALL ERRORS("FIELD_TYPE_SET_NUMBER",ERR,ERROR)
    CALL EXITS("FIELD_TYPE_SET_NUMBER")
    RETURN 1
  END SUBROUTINE FIELD_TYPE_SET_NUMBER
  
  !
  !================================================================================================================================
  !

  !>Sets/changes the field type for a field identified by a pointer.
  SUBROUTINE FIELD_TYPE_SET_PTR(FIELD,TYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to set the type for
    INTEGER(INTG), INTENT(IN) :: TYPE !<The field type to set \see FIELD_ROUTINES_FieldTypes,FIELD_ROUTINES
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_TYPE_SET_PTR",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(FIELD%FIELD_FINISHED) THEN
        CALL FLAG_ERROR("Field has been finished",ERR,ERROR,*999)
      ELSE
        SELECT CASE(TYPE)
        CASE(FIELD_GEOMETRIC_TYPE)
          FIELD%TYPE=FIELD_GEOMETRIC_TYPE
          FIELD%GEOMETRIC_FIELD=>FIELD
        CASE(FIELD_FIBRE_TYPE)
          FIELD%TYPE=FIELD_FIBRE_TYPE
          NULLIFY(FIELD%GEOMETRIC_FIELD)
        CASE(FIELD_GENERAL_TYPE)
          FIELD%TYPE=FIELD_GENERAL_TYPE
          NULLIFY(FIELD%GEOMETRIC_FIELD)
        CASE(FIELD_MATERIAL_TYPE)
          FIELD%TYPE=FIELD_MATERIAL_TYPE
          NULLIFY(FIELD%GEOMETRIC_FIELD)
        CASE DEFAULT
          LOCAL_ERROR="Field type "//TRIM(NUMBER_TO_VSTRING(TYPE,"*",ERR,ERROR))//" is not valid"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_TYPE_SET_PTR")
    RETURN
999 CALL ERRORS("FIELD_TYPE_SET_PTR",ERR,ERROR)
    CALL EXITS("FIELD_TYPE_SET_PTR")
    RETURN 1
  END SUBROUTINE FIELD_TYPE_SET_PTR
  
  !
  !================================================================================================================================
  !
  
  !>Finds and returns in FIELD a pointer to the field identified by USER_NUMBER in the given REGION. If no field with that USER_NUMBER exists FIELD is left nullified.
  SUBROUTINE FIELD_USER_NUMBER_FIND(USER_NUMBER,REGION,FIELD,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(IN) :: USER_NUMBER !<The field user number to find
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region containing the field
    TYPE(FIELD_TYPE), POINTER :: FIELD !<On exit, a pointer to the field with the given user number. If no field with that user number exists in the region the FIELD is null.
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: field_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_USER_NUMBER_FIND",ERR,ERROR,*999)

    NULLIFY(FIELD)
    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%FIELDS)) THEN
        field_idx=1
        DO WHILE(field_idx<=REGION%FIELDS%NUMBER_OF_FIELDS.AND..NOT.ASSOCIATED(FIELD))
          IF(REGION%FIELDS%FIELDS(field_idx)%PTR%USER_NUMBER==USER_NUMBER) THEN
            FIELD=>REGION%FIELDS%FIELDS(field_idx)%PTR
          ELSE
            field_idx=field_idx+1
          ENDIF
        ENDDO
      ELSE
        LOCAL_ERROR="The fields on region number "//TRIM(NUMBER_TO_VSTRING(REGION%USER_NUMBER,"*",ERR,ERROR))// &
          & " are not associated"
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_USER_NUMBER_FIND")
    RETURN
999 CALL ERRORS("FIELD_USER_NUMBER_FIND",ERR,ERROR)
    CALL EXITS("FIELD_USER_NUMBER_FIND")
    RETURN 1
  END SUBROUTINE FIELD_USER_NUMBER_FIND

  !
  !================================================================================================================================
  !

  !>Finalises a field variable and deallocates all memory.
  SUBROUTINE FIELD_VARIABLE_FINALISE(FIELD_VARIABLE,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_VARIABLE_TYPE) :: FIELD_VARIABLE !<The field variable to finalise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELD_VARIABLE_FINALISE",ERR,ERROR,*999)

    CALL FIELD_VARIABLE_COMPONENTS_FINALISE(FIELD_VARIABLE,ERR,ERROR,*999)
    IF(ALLOCATED(FIELD_VARIABLE%DOF_LIST)) DEALLOCATE(FIELD_VARIABLE%DOF_LIST)
    IF(ASSOCIATED(FIELD_VARIABLE%DOMAIN_MAPPING)) THEN
      CALL DOMAIN_MAPPINGS_MAPPING_FINALISE(FIELD_VARIABLE%DOMAIN_MAPPING,ERR,ERROR,*999)
      DEALLOCATE(FIELD_VARIABLE%DOMAIN_MAPPING)
    ENDIF
    
    CALL EXITS("FIELD_VARIABLE_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises a field variable.
  SUBROUTINE FIELD_VARIABLE_INITIALISE(FIELD,VARIABLE_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the variable for
    INTEGER(INTG), INTENT(IN) :: VARIABLE_NUMBER !<The variable number of the field to initialise
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("FIELD_VARIABLE_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ASSOCIATED(FIELD%CREATE_VALUES_CACHE)) THEN
        IF(VARIABLE_NUMBER>=1.AND.VARIABLE_NUMBER<=FIELD%NUMBER_OF_VARIABLES) THEN
          FIELD%VARIABLES(VARIABLE_NUMBER)%VARIABLE_NUMBER=VARIABLE_NUMBER
          FIELD%VARIABLES(VARIABLE_NUMBER)%VARIABLE_TYPE=FIELD%CREATE_VALUES_CACHE%VARIABLE_TYPES(VARIABLE_NUMBER)
          FIELD%VARIABLE_TYPE_MAP(FIELD%VARIABLES(VARIABLE_NUMBER)%VARIABLE_TYPE)%PTR=>FIELD%VARIABLES(VARIABLE_NUMBER)
          FIELD%VARIABLES(VARIABLE_NUMBER)%FIELD=>FIELD
          FIELD%VARIABLES(VARIABLE_NUMBER)%REGION=>FIELD%REGION
          FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS=FIELD%CREATE_VALUES_CACHE%NUMBER_OF_COMPONENTS
          CALL FIELD_VARIABLE_COMPONENTS_INITIALISE(FIELD,VARIABLE_NUMBER,ERR,ERROR,*999)
          FIELD%VARIABLES(VARIABLE_NUMBER)%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS=-1  
          DO component_idx=1,FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_COMPONENTS
            IF(FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(component_idx)%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS>FIELD% &
              & VARIABLES(VARIABLE_NUMBER)%MAX_NUMBER_OF_INTERPOLATION_PARAMETERS) FIELD%VARIABLES(VARIABLE_NUMBER)% &
              & MAX_NUMBER_OF_INTERPOLATION_PARAMETERS=FIELD%VARIABLES(VARIABLE_NUMBER)%COMPONENTS(component_idx)% &
              & MAX_NUMBER_OF_INTERPOLATION_PARAMETERS
          ENDDO !component_idx
          FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_DOFS=0
          FIELD%VARIABLES(VARIABLE_NUMBER)%TOTAL_NUMBER_OF_DOFS=0
          FIELD%VARIABLES(VARIABLE_NUMBER)%NUMBER_OF_GLOBAL_DOFS=0
          IF(FIELD%DEPENDENT_TYPE==FIELD_DEPENDENT_TYPE) THEN
            ALLOCATE(FIELD%VARIABLES(VARIABLE_NUMBER)%DOMAIN_MAPPING,STAT=ERR)
            IF(ERR/=0) CALL FLAG_ERROR("Could not allocate field variable domain mapping",ERR,ERROR,*999)
            CALL DOMAIN_MAPPINGS_MAPPING_INITIALISE(FIELD%VARIABLES(VARIABLE_NUMBER)%DOMAIN_MAPPING, &
              & FIELD%DECOMPOSITION%NUMBER_OF_DOMAINS,ERR,ERROR,*999)            
          ELSE
            NULLIFY(FIELD%VARIABLES(VARIABLE_NUMBER)%DOMAIN_MAPPING)
          ENDIF
        ELSE
          LOCAL_ERROR="Variable number "//TRIM(NUMBER_TO_VSTRING(VARIABLE_NUMBER,"*",ERR,ERROR))// &
            & " is invalid for field number "//TRIM(NUMBER_TO_VSTRING(FIELD%USER_NUMBER,"*",ERR,ERROR))//" which has "// &
            & TRIM(NUMBER_TO_VSTRING(FIELD%NUMBER_OF_VARIABLES,"*",ERR,ERROR))//" variables"
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Field create values cache is not associated",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FIELD_VARIABLE_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLE_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLE_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLE_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finalises the field variables for a field and deallocates all memory.
  SUBROUTINE FIELD_VARIABLES_FINALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to finalise the variables for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx

    CALL ENTERS("FIELD_VARIABLES_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ALLOCATED(FIELD%VARIABLES)) THEN
        DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
          CALL FIELD_VARIABLE_FINALISE(FIELD%VARIABLES(variable_idx),ERR,ERROR,*999)
        ENDDO !variable_idx
        DEALLOCATE(FIELD%VARIABLES)
      ENDIF
      FIELD%NUMBER_OF_VARIABLES=0
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("FIELD_VARIABLES_FINALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLES_FINALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLES_FINALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLES_FINALISE

  !
  !================================================================================================================================
  !

  !>Initialises the field variables.
  SUBROUTINE FIELD_VARIABLES_INITIALISE(FIELD,ERR,ERROR,*)

    !Argument variables
    TYPE(FIELD_TYPE), POINTER :: FIELD !<A pointer to the field to initialise the variables for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: variable_idx
    
    CALL ENTERS("FIELD_VARIABLES_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(FIELD)) THEN
      IF(ALLOCATED(FIELD%VARIABLES)) THEN
        CALL FLAG_ERROR("Field already has associated variables",ERR,ERROR,*999)
      ELSE
        ALLOCATE(FIELD%VARIABLES(FIELD%NUMBER_OF_VARIABLES),STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Could not allocate new field variables",ERR,ERROR,*999)
        DO variable_idx=1,FIELD%NUMBER_OF_VARIABLES
          CALL FIELD_VARIABLE_INITIALISE(FIELD,variable_idx,ERR,ERROR,*999)
        ENDDO !variable_idx
      ENDIF
    ELSE
      CALL FLAG_ERROR("Field is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELD_VARIABLES_INITIALISE")
    RETURN
999 CALL ERRORS("FIELD_VARIABLES_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELD_VARIABLES_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELD_VARIABLES_INITIALISE

  !
  !================================================================================================================================
  !

  !>Finalises the fields for the given region and deallocates all memory.
  SUBROUTINE FIELDS_FINALISE(REGION,ERR,ERROR,*)

    !Argument variables
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region to finalise the fields for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: FIELD

    CALL ENTERS("FIELDS_FINALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%FIELDS)) THEN
        DO WHILE(REGION%FIELDS%NUMBER_OF_FIELDS>0)
          FIELD=>REGION%FIELDS%FIELDS(1)%PTR
          CALL FIELD_DESTROY(FIELD,ERR,ERROR,*999)
        ENDDO !field_idx
        DEALLOCATE(REGION%FIELDS)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELDS_FINALISE")
    RETURN
999 CALL ERRORS("FIELDS_FINALISE",ERR,ERROR)
    CALL EXITS("FIELDS_FINALISE")
    RETURN 1
  END SUBROUTINE FIELDS_FINALISE
  
  !
  !================================================================================================================================
  !

  !>Initialises the fields for the given region.
  SUBROUTINE FIELDS_INITIALISE(REGION,ERR,ERROR,*)

    !Argument variables
    TYPE(REGION_TYPE), POINTER :: REGION !<A pointer to the region to initialise the fields for
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables

    CALL ENTERS("FIELDS_INITIALISE",ERR,ERROR,*999)

    IF(ASSOCIATED(REGION)) THEN
      IF(ASSOCIATED(REGION%FIELDS)) THEN
        CALL FLAG_ERROR("Region already has fields associated",ERR,ERROR,*999)
      ELSE        
        ALLOCATE(REGION%FIELDS,STAT=ERR)
        IF(ERR/=0) CALL FLAG_ERROR("Region fields could not be allocated",ERR,ERROR,*999)
        !!TODO: Inherit any fields from the parent region        
        REGION%FIELDS%NUMBER_OF_FIELDS=0
        NULLIFY(REGION%FIELDS%FIELDS)
        REGION%FIELDS%REGION=>REGION
      ENDIF
    ELSE
      CALL FLAG_ERROR("Region is not associated",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("FIELDS_INITIALISE")
    RETURN
999 CALL ERRORS("FIELDS_INITIALISE",ERR,ERROR)
    CALL EXITS("FIELDS_INITIALISE")
    RETURN 1
  END SUBROUTINE FIELDS_INITIALISE
   
END MODULE FIELD_ROUTINES