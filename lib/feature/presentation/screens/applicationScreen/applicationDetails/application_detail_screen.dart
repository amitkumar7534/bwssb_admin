import 'package:bwssb/utils/extensions/widget.dart';
import 'package:flutter/material.dart';
import 'package:bwssb/components/coreComponents/TextView.dart';
import 'package:bwssb/components/coreComponents/EditText.dart';
import 'package:bwssb/components/styles/textStyles.dart';
import 'package:bwssb/utils/extensions/size.dart';
import '../../../../data/models/dataModels/get_all_details_model.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final GetAllDetailsModel details;
  const ApplicationDetailScreen({super.key, required this.details});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool hasExistingConnection = false;

  @override
  void initState() {
    super.initState();
    hasExistingConnection =
        widget.details.connectionDetails?.connectionDetails?.isBwssbConnection != 0;
  }


  late final TextEditingController nameController = TextEditingController(
    text: widget.details.connectionDetails?.consumerDetails?.name ?? 'N/A',
  );


  late final TextEditingController mobileController = TextEditingController(
    text: widget.details.connectionDetails?.consumerDetails?.mobile ?? 'N/A',
  );


  late final TextEditingController emailController = TextEditingController(
    text: widget.details.connectionDetails?.consumerDetails?.email ?? 'N/A',
  );


  late final TextEditingController stateController = TextEditingController(
    text: widget.details.connectionDetails?.communicationDetails?.state ?? 'N/A',
  );

  late final TextEditingController districtController = TextEditingController(
    text: widget.details.connectionDetails?.communicationDetails?.state ?? 'N/A',
  );

  late final TextEditingController talukController = TextEditingController(
    text: widget.details.connectionDetails?.communicationDetails?.talukName.toString() ?? "N/A",
  );

  late final TextEditingController landmarkController = TextEditingController(
    text: widget.details.connectionDetails?.communicationDetails?.landmark ?? "N/A",
  );


  late final TextEditingController connectionLandmarkController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.connectionLandmark ?? "N/A",
  );




  late final TextEditingController addressController = TextEditingController(
    text: widget.details.connectionDetails?.communicationDetails?.address ?? 'N/A',
  );

  late final TextEditingController pinCodeController = TextEditingController(
    text: widget.details.connectionDetails?.communicationDetails?.pincode ?? 'N/A',
  );

  late final TextEditingController street1Controller = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.street1 ?? 'N/A',
  );

  late final TextEditingController street2Controller = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.street2 ?? 'N/A',
  );

  late final TextEditingController ConnectionAddresspinCodeController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.pincode ?? 'N/A',
  );

  late final TextEditingController ServiceStationNameController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.serviceStationName ?? 'N/A',
  );

  late final TextEditingController DivisionNameController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.divisionName ?? 'N/A',
  );
  late final TextEditingController SubDivisionNameController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.subdivisionName ?? 'N/A',
  );


  late final TextEditingController wardCombinedController = TextEditingController(
    text:
    "${widget.details.connectionDetails?.connectionDetails?.wardNo?.toString() ?? 'N/A'} , "
        "${widget.details.connectionDetails?.connectionDetails?.subdivisionName ?? 'N/A'}",
  );


  late final TextEditingController ServiceAddressController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.serviceareaName ?? 'N/A',
  );


  late final TextEditingController rrNumberController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.rrDetails?.rrNumber ?? 'N/A',
  );


  late final TextEditingController consumerNameController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.rrDetails?.consumerName ?? 'N/A',
  );



  late final TextEditingController addressRrDetailsController = TextEditingController(
    text: widget.details.connectionDetails?.connectionDetails?.rrDetails?.address ?? 'N/A',
  );



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 16.all,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(text: "Consumer Details", style: 16.txtBoldBtncolor),
            EditText(
              readOnly: true,
              controller: nameController,
              hint: "Enter Name",
              padding: 20.top + 20.bottom + 12.left,
              label: "Applicant name".toUpperCase(),
              labelStyle: 14.txtRegularBlack,
              borderColor: Colors.transparent,
              margin: 10.bottom + 10.top,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your applicant name'.toUpperCase();
                }
                return null;
              },
            ),

            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: mobileController,
                    hint: "Enter Mobile No",
                    label: "Mobile No".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: emailController,
                    hint: "Enter Email",
                    label: "Email".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    maxLength: 1,
                    maxLines: 2,
                  ),
                ),
              ],
            ),

            TextView(text: "Communication Address", style: 16.txtBoldBtncolor,margin: 10.top + 10.bottom,),

            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: stateController,
                    hint: "Select State",
                    label: "State".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter state'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: districtController,
                    hint: "Select District",
                    label: "District".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: talukController,
                    hint: "Select Taluk",
                    label: "Taluk".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter taluk'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: landmarkController,
                    hint: "Enter Landmark",
                    label: "Landmark".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              ],
            ),

            EditText(
              readOnly: true,
              controller: addressController,
              hint: "Enter Address Here",
              label: "Address".toUpperCase(),
              labelStyle: 14.txtRegularBlack,
              margin: 10.bottom + 10.top,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address'.toUpperCase();
                }
                return null;
              },
            ),


            EditText(
              readOnly: true,
              controller: pinCodeController,
              hint: "Select pincode",
              label: "Pincode".toUpperCase(),
              labelStyle: 14.txtRegularBlack,
              margin: 10.bottom + 10.top,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pincode'.toUpperCase();
                }
                return null;
              },
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextView(
                text: "Connection Address",
                style: 16.txtBoldBtncolor,
                maxlines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: ConnectionAddresspinCodeController,
                    hint: "Select Pincode",
                    label: "Pincode".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pincode'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
                16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: ServiceAddressController,
                    hint: "Select Service area",
                    label: "Service area".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              ],
            ),
            EditText(
              readOnly: true,
              controller: street1Controller,
              hint: "Street1",
              label: "Street1".toUpperCase(),
              labelStyle: 14.txtRegularBlack,
              margin: 10.bottom + 10.top,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pincode'.toUpperCase();
                }
                return null;
              },
            ),

            EditText(
              readOnly: true,
              controller: street2Controller,
              hint: "Street2",
              label: "Street2".toUpperCase(),
              labelStyle: 14.txtRegularBlack,
              margin: 10.bottom + 10.top,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pinCode'.toUpperCase();
                }
                return null;
              },
            ),

            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: connectionLandmarkController,
                    hint: "Enter Landmark",
                    label: "Landmark".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: ServiceStationNameController,
                    label: "Service Station".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              16.width,
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: DivisionNameController,
                    label: "Division".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: EditText(
                    readOnly: true,
                    controller: SubDivisionNameController,
                    label: "Sub Division".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter sub division'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                ),
               16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: "WARD NO & NAME",
                        style: 14.txtRegularBlack,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      EditText(
                        readOnly: true,
                        controller: wardCombinedController,
                        margin: 3.top,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'PLEASE ENTER WARD NO AND NAME';
                          }
                          return null;
                        },
                        maxLines: null,

                      ),
                    ],
                  ),
                ),

              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: 5.top + 5.bottom,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextView(
                          text: "Do you have an existing BWSSB connection in the premise?"
                              .toUpperCase(),
                          style: 16.txtRegularBlack,
                          maxlines: 2,
                        ),
                      ),
                      10.width,
                      Padding(
                        padding: 8.all,
                        child: TextView(
                          text: hasExistingConnection ? "Yes" : "No",
                          style: 16.txtRegularBlack,
                        ),
                      ),
                    ],
                  ),
                ),


                if (hasExistingConnection)
                  EditText(
                    controller: rrNumberController,
                    readOnly: true,
                    hint: "Enter Rr Number",
                    label: "RR Number".toUpperCase(),
                    labelStyle: 14.txtRegularBlack,
                    margin: 10.bottom + 10.top,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter rr number'.toUpperCase();
                      }
                      return null;
                    },
                  ),
                if (hasExistingConnection)
                Row(
                  children: [
                    Expanded(
                      child: EditText(
                        readOnly: true,
                        controller: consumerNameController,
                        label: "Name".toUpperCase(),
                        labelStyle: 14.txtRegularBlack,
                        margin: 10.bottom + 10.top,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter sub division'.toUpperCase();
                          }
                          return null;
                        },
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: "Address".toUpperCase(),
                            style: 14.txtRegularBlack,
                            maxlines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          EditText(
                            readOnly: true,
                            controller: addressRrDetailsController,
                            margin: 3.top,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'PLEASE ENTER WARD NO AND NAME';
                              }
                              return null;
                            },
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            )


          ],
        ),
      ),
    );
  }
}

