import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import DarkStyle.Controls 1.0
import DarkStyle 1.0
import NodeEditor 1.0

Rectangle {

    id : root
    property variant model: null

    Component {
        id: emptyDelegate
        Item {}
    }
    Component {
        id: labelDelegate
        Text {
            text: modelData.name
            font.pixelSize: Style.text.size.xsmall
        }
    }
    Component {
        id: listDelegate
        ListView {
            implicitWidth: 100
            implicitHeight: 80
            model: modelData.value
            delegate: Rectangle {
                width: ListView.view.width
                height: 20
                color: Style.window.color.dark
                Text {
                    anchors.fill: parent
                    anchors.margins: 2
                    text: modelData
                    font.pixelSize: Style.text.size.xsmall
                }
            }
        }
    }
    Component {
        id: sliderDelegate
        Slider {
            // minimumValue: modelData.min
            Component.onCompleted: minimumValue = modelData.min // workaround
            maximumValue: modelData.max
            stepSize: modelData.step
            value: modelData.value
            onValueChanged: modelData.value = value
            updateValueWhileDragging: true
        }
    }
    Component {
        id: textfieldDelegate
        TextField {
            text: modelData.value
            onEditingFinished: modelData.value = text
        }
    }
    Component {
        id: comboboxDelegate
        ComboBox {
            model: modelData.options
            onActivated: {
                modelData.value = textAt(index);
                currentIndex = index;
            }
            Component.onCompleted: currentIndex = find(modelData.value)
        }
    }
    Component {
        id: checkboxDelegate
        CheckBox {
            checked: modelData.value
            pressed: modelData.value = checked
        }
    }

    color: Style.window.color.normal

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Text { // title
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.margins: 5
            text: root.model ? root.model.name : ""
            font.pixelSize: Style.text.size.small
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
        Rectangle { // separator
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            color: Style.window.color.xdark
        }
        ScrollView {
            id: scrollview
            Layout.fillHeight: true
            Layout.fillWidth: true
            GridLayout {
                width: scrollview.width - 8
                x: 4
                columns: 2
                rowSpacing: 5
                columnSpacing: 5
                Repeater {
                    model: root.model ? root.model.inputs.count*2 : 0
                    delegate: Loader {
                        Layout.fillWidth: index%2 != 0
                        Layout.preferredWidth: index%2 ? parent.width : parent.width*0.3
                        property variant modelData: root.model.inputs.get(index/2)
                        sourceComponent: {
                            if(index % 2 == 0)
                                return labelDelegate;
                            if(Array.isArray(modelData.value))
                                return listDelegate;
                            switch(modelData.type) {
                                case Attribute.UNKNOWN: return emptyDelegate
                                case Attribute.TEXTFIELD: return textfieldDelegate
                                case Attribute.SLIDER: return sliderDelegate
                                case Attribute.COMBOBOX: return comboboxDelegate
                                case Attribute.CHECKBOX: return checkboxDelegate
                            }
                        }
                    }
                }
            }
        }
    }

}
