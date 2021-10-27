//
//  htmlStrings.swift
//  ScanBeacons
//
//  Created by Wei-Cheng Ling on 2021/10/25.
//

import Foundation


let TableHTML = """
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes" />
    <style>
        table {
            font-family: arial, sans-serif;
            /*text-align: center;*/
            border-collapse: collapse;
            width: 100%;
        }

        td, th {
            padding: 15px 18px;
        }

        table tr {
            border-bottom: 1px solid #dddddd;
        }

        .title1 {
            color: #EA7500;
            font-weight: bolder;
            width: 100%;
            padding: 0px 0px 8px 0px;
            font-size: 1.05em;
            text-decoration: underline;
        }

        .title2 {
            color: #0072E3;
            font-weight: bolder;
            width: 100%;
            padding: 0px 0px 12px 0px;
            font-size: 1.1em;
        }

        #subTable {
            text-align: center;
        }

        #subTable td, th {
            padding: 0px 0px 0px 0px;
        }
        
        #subTable tr:last-child {
            border: 0;
        }
        
    </style>
</head>
<body>
    <table id="mainTable"></table>
</body>
<script>
    function table_removeAllRows() {
        let table = document.getElementById('mainTable');
        let rowCount = table.rows.length;
        for (let i = rowCount-1; i >= 0; i--) {
           table.deleteRow(i);
        }
    }

    function table_addRows(jsonString) {
        table_removeAllRows();
        let rows = JSON.parse(jsonString);
        for (const item of rows) {
            let table = document.getElementById('mainTable');
            let row = table.insertRow();
            let cell = row.insertCell();
            cell.innerHTML = `<div class="title1">${item["name"]}</div>
                              <div class="title2">${item["proximityUUID"]}</div>
                              <table id="subTable">
                              <tr>
                                <td>Major : ${item["major"]}</td>
                                <td>Minor : ${item["minor"]}</td>
                                <td>RSSI : ${item["rssi"]}</td>
                              </tr>
                              </table>`;
        }
    }
</script>
</html>
"""

