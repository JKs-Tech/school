import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/screens/fees/controller/admin_fees_controller.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/screens/fees/model/FeesAdminAddPaymentModel.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

class FeesAdminAddPayment extends StatefulWidget {
  final int invoiceId;
  const FeesAdminAddPayment(this.invoiceId, {super.key});
  @override
  _FeesAdminAddPaymentState createState() => _FeesAdminAddPaymentState();
}

class _FeesAdminAddPaymentState extends State<FeesAdminAddPayment> {
  final AdminFeesController _controller = Get.put(AdminFeesController());
  String? appLogo;
  @override
  void initState() {
    _controller.getFeesInvoice(widget.invoiceId);
    Utils.getStringValue('appLogo').then((value) {
      setState(() {
        appLogo = value;
      });
    });
    super.initState();
  }

  File? _file;

  Future pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    setState(() {
      _file = File(result?.files.single.path ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'Add Payment'),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        } else {
          return Stack(
            children: [
              _controller.isPaymentProcessing.value
                  ? const Center(child: CircularProgressIndicator())
                  : Container(),
              Opacity(
                opacity: _controller.isPaymentProcessing.value ? 0.2 : 1.0,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        appLogo != null
                            ? CachedNetworkImage(
                              imageUrl: '$appLogo?${Random().nextInt(11)}',
                              width: Get.width * 0.2,
                              height: Get.width * 0.2,
                              errorWidget:
                                  (context, url, error) => Image.asset(
                                    AppConfig.appLogo,
                                    width: Get.width * 0.2,
                                    height: Get.width * 0.2,
                                  ),
                            )
                            : Image.asset(
                              AppConfig.appLogo,
                              width: Get.width * 0.2,
                              height: Get.width * 0.2,
                            ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "${'Invoice'.tr}: ${_controller.feesAdminAddPaymentModel.value.invoiceInfo?.invoiceId}",
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${'Due Date'.tr}: ${DateFormat.yMMMd().format(_controller.feesAdminAddPaymentModel.value.invoiceInfo?.dueDate ?? DateTime.now())}",
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${'Wallet Balance'.tr}: ${_controller.feesAdminAddPaymentModel.value.walletBalance?.toStringAsFixed(2)}",
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Obx(() {
                              if (_controller.addWalletList.isNotEmpty) {
                                return Text(
                                  "${'Add in Wallet'.tr}: ${_controller.addWalletList.reduce((a, b) => a + b).toStringAsFixed(2)}",
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                );
                              } else {
                                return Text(
                                  "${'Add in Wallet'.tr}: 0.00",
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                );
                              }
                            }),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Fees List'.tr,
                      maxLines: 1,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount:
                          _controller
                              .feesAdminAddPaymentModel
                              .value
                              .invoiceDetails
                              ?.length ??
                          0,
                      itemBuilder: (context, index) {
                        InvoiceDetail invoiceDetails =
                            _controller
                                .feesAdminAddPaymentModel
                                .value
                                .invoiceDetails![index];

                        return FeesListRow(
                          invoiceDetails: invoiceDetails,
                          index: index,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      return DropdownButton(
                        elevation: 0,
                        isExpanded: true,
                        hint: Text(
                          "Select Payment Method.".tr,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        items:
                            _controller
                                .feesAdminAddPaymentModel
                                .value
                                .paymentMethods
                                ?.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.method,
                                    child: Text(
                                      item.method ?? 'NA',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                    ),
                                  );
                                })
                                .toList(),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 13.0),
                        onChanged: (value) {
                          _controller.selectedPaymentMethod.value = value ?? '';

                          _controller.chequeBankOrOthers();
                        },
                        value: _controller.selectedPaymentMethod.value,
                      );
                    }),
                    const SizedBox(height: 20),
                    Obx(() {
                      if (_controller.isBank.value) {
                        return DropdownButton(
                          elevation: 0,
                          isExpanded: true,
                          hint: Text(
                            "Select Bank".tr,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          items:
                              _controller
                                  .feesAdminAddPaymentModel
                                  .value
                                  .bankAccounts
                                  ?.map((item) {
                                    return DropdownMenuItem<BankAccount>(
                                      value: item,
                                      child: Text(
                                        "${item.bankName} (${item.accountNumber})",
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.headlineMedium,
                                      ),
                                    );
                                  })
                                  .toList(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 13.0),
                          onChanged: (value) {
                            _controller.selectedBank.value =
                                value ?? BankAccount();
                          },
                          value: _controller.selectedBank.value,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                    Obx(() {
                      if (_controller.isCheque.value ||
                          _controller.isBank.value) {
                        return Column(
                          children: [
                            TextField(
                              style: Theme.of(context).textTheme.headlineMedium,
                              controller: _controller.paymentNoteController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: "Note".tr,
                                hintStyle:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                pickDocument();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          _file == null
                                              ? _controller.isBank.value == true
                                                  ? 'Select Bank payment slip'
                                                      .tr
                                                  : 'Select Cheque payment slip'
                                                      .tr
                                              : _file?.path.split('/').last ??
                                                  '',
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Browse',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium?.copyWith(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (_controller.selectedPaymentMethod.value == "Bank" ||
                            _controller.selectedPaymentMethod.value ==
                                "Cheque") {
                          _controller.submitPayment(
                            file: _file ?? File(''),
                            context: context,
                          );
                        } else {
                          _controller.submitPayment(
                            context: context,
                            file: File(''),
                          );
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * .5,
                          height: 50.0,
                          alignment: Alignment.center,
                          decoration: Utils.gradientBtnDecoration,
                          child: Text(
                            "Pay".tr,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}

class FeesListRow extends StatefulWidget {
  final InvoiceDetail invoiceDetails;
  final int index;
  const FeesListRow({
    super.key,
    required this.invoiceDetails,
    required this.index,
  });
  @override
  _FeesListRowState createState() => _FeesListRowState();
}

class _FeesListRowState extends State<FeesListRow> {
  final AdminFeesController _controller = Get.put(AdminFeesController());

  double? dueAmount;
  double? weaverAmount;
  double? fineAmount;

  double? currentDue;
  double? currentWeaver;
  double? currentFine;

  @override
  void initState() {
    dueAmount = widget.invoiceDetails.dueAmount;
    fineAmount = widget.invoiceDetails.fine;
    weaverAmount = widget.invoiceDetails.weaver;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        _controller.feesAdminAddPaymentModel.value.feesTypes
                ?.where(
                  (element) => element.id == widget.invoiceDetails.feesType,
                )
                .first
                .name ??
            'NA',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Amount'.tr,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          maxLines: 1,
                          enabled: false,
                          style: Theme.of(context).textTheme.headlineMedium,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(?!\.)(\d+)?\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: widget.invoiceDetails.amount
                                ?.toStringAsFixed(2),
                            hintStyle:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Due'.tr,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          maxLines: 1,
                          enabled: false,
                          style: Theme.of(context).textTheme.headlineMedium,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(?!\.)(\d+)?\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText:
                                double.parse(
                                  _controller.dueList[widget.index].toString(),
                                ).toStringAsFixed(2).tr,
                            hintStyle:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Paid Amount'.tr,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          maxLines: 1,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(?!\.)(\d+)?\.?\d{0,2}'),
                            ),
                          ],
                          onChanged: (text) {
                            setState(() {
                              if (text.isNotEmpty) {
                                var currentText = double.parse(text.toString());
                                currentDue = (dueAmount ?? 0) - currentText;

                                if (currentText >= (dueAmount ?? 0)) {
                                  currentDue = 0.0;

                                  _controller.addWalletList[widget.index] =
                                      currentText - (dueAmount ?? 0);
                                } else {
                                  _controller.addWalletList[widget.index] = 0;
                                }

                                _controller.paidAmountList[widget.index] =
                                    currentText;

                                _controller.dueList[widget.index] = currentDue;

                                _controller.totalPaidAmount.value = _controller
                                    .paidAmountList
                                    .reduce(
                                      (previousValue, element) =>
                                          previousValue + element,
                                    );
                              } else {
                                _controller.dueList[widget.index] =
                                    widget.invoiceDetails.dueAmount;
                              }
                            });
                          },
                          style: Theme.of(context).textTheme.headlineMedium,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: "Paid Amount".tr,
                            hintStyle:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Weaver'.tr,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        maxLines: 1,
                        enabled: false,
                        initialValue:
                            _controller.weaverList[widget.index].toString(),
                        onChanged: (text) {
                          setState(() {
                            if (text.isNotEmpty) {
                              var currentText = double.parse(text.toString());
                              currentWeaver = (weaverAmount ?? 0) - currentText;

                              if (currentText >= (weaverAmount ?? 0)) {
                                currentDue = 0.0;

                                _controller.addWalletList[widget.index] =
                                    currentText - (weaverAmount ?? 0);
                              } else {
                                _controller.addWalletList[widget.index] = 0;
                              }
                              _controller.weaverList[widget.index] =
                                  currentText;
                            } else {
                              _controller.weaverList[widget.index] =
                                  widget.invoiceDetails.weaver;
                            }
                          });
                        },
                        style: Theme.of(context).textTheme.headlineMedium,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: "Weaver".tr,
                          hintStyle: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Fine'.tr,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        maxLines: 1,
                        enabled: true,
                        initialValue:
                            _controller.fineList[widget.index].toString(),
                        onChanged: (text) {
                          setState(() {
                            if (text.isNotEmpty) {
                              var currentText = double.parse(text.toString());
                              currentDue = (dueAmount ?? 0) + currentText;
                              _controller.fineList[widget.index] = currentText;
                            } else {
                              currentDue = widget.invoiceDetails.dueAmount;
                            }
                          });
                        },
                        style: Theme.of(context).textTheme.headlineMedium,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: "Fine".tr,
                          hintStyle: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Note'.tr,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        maxLines: 1,
                        enabled: true,
                        style: Theme.of(context).textTheme.headlineMedium,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            _controller.noteList[widget.index] = text;
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: "Note".tr,
                          hintStyle: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
