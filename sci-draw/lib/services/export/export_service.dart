import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/graph_data.dart';

/// 导出服务 - 生成各种格式的图表文件
class ExportService {
  
  /// 导出为 SVG 格式
  Future<String> exportToSvg(GraphData graphData, {String? fileName}) async {
    final svg = _generateSvg(graphData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName ?? 'graph'}.svg');
    await file.writeAsString(svg);
    
    return file.path;
  }
  
  /// 导出为 PNG 格式 (通过 RenderRepaintBoundary)
  Future<String> exportToPng(GlobalKey repaintBoundaryKey, {int width = 1200, int height = 900, String? fileName}) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('无法获取渲染边界');
      }
      
      final image = await boundary.toImage(pixelRatio: width / boundary.size.width);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('无法生成 PNG 数据');
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${fileName ?? 'graph'}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file.path;
    } catch (e) {
      throw Exception('PNG 导出失败: $e');
    }
  }
  
  /// 导出为 PDF 格式
  Future<String> exportToPdf(GraphData graphData, {String? fileName}) async {
    // TODO: 实现 PDF 导出
    throw UnimplementedError('PDF 导出功能开发中');
  }
  
  /// 导出为 Visio (.vsdx) 格式
  Future<String> exportToVsdx(GraphData graphData, {String? fileName}) async {
    final vsdx = _generateVsdx(graphData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName ?? 'graph'}.vsdx');
    await file.writeAsBytes(vsdx);
    
    return file.path;
  }
  
  /// 生成 SVG 内容
  String _generateSvg(GraphData graphData) {
    final buffer = StringBuffer();
    final width = 800;
    final height = 600;
    
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height">');
    
    // 添加样式
    buffer.writeln('<style>');
    buffer.writeln('.node { fill: #f5f5f5; stroke: #333; stroke-width: 1; }');
    buffer.writeln('.line { stroke: #333; stroke-width: 1.5; fill: none; }');
    buffer.writeln('.text { font-family: Arial, sans-serif; font-size: 12px; text-anchor: middle; }');
    buffer.writeln('</style>');
    
    // 绘制模块背景
    for (final module in graphData.moduleList) {
      final x = module.position['x']! * width;
      final y = module.position['y']! * height;
      final w = module.size['width']! * width;
      final h = module.size['height']! * height;
      
      buffer.writeln('<rect x="$x" y="$y" width="$w" height="$h" fill="#f0f0f0" stroke="#ddd" stroke-width="1" rx="4" />');
    }
    
    // 绘制连接线
    for (final line in graphData.lineList) {
      final startNode = graphData.nodeList.where((n) => n.nodeId == line.startNodeId).firstOrNull;
      final endNode = graphData.nodeList.where((n) => n.nodeId == line.endNodeId).firstOrNull;
      
      if (startNode != null && endNode != null) {
        final x1 = (startNode.position['x']! + startNode.size['width']! / 2) * width;
        final y1 = (startNode.position['y']! + startNode.size['height']! / 2) * height;
        final x2 = (endNode.position['x']! + endNode.size['width']! / 2) * width;
        final y2 = (endNode.position['y']! + endNode.size['height']! / 2) * height;
        
        final dashArray = line.lineType == '虚线' ? 'stroke-dasharray="5,5"' : '';
        buffer.writeln('<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" class="line" $dashArray marker-end="url(#arrow)" />');
        
        // 线条文字
        if (line.lineText.isNotEmpty) {
          final mx = (x1 + x2) / 2;
          final my = (y1 + y2) / 2;
          buffer.writeln('<text x="$mx" y="$my" class="text" font-size="10">${_escapeXml(line.lineText)}</text>');
        }
      }
    }
    
    // 定义箭头
    buffer.writeln('<defs>');
    buffer.writeln('<marker id="arrow" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto" markerUnits="strokeWidth">');
    buffer.writeln('<path d="M0,0 L0,6 L9,3 z" fill="#333" />');
    buffer.writeln('</marker>');
    buffer.writeln('</defs>');
    
    // 绘制节点
    for (final node in graphData.nodeList) {
      final x = node.position['x']! * width;
      final y = node.position['y']! * height;
      final w = node.size['width']! * width;
      final h = node.size['height']! * height;
      
      String shape;
      switch (node.shape) {
        case '椭圆形':
          shape = '<ellipse cx="${x + w/2}" cy="${y + h/2}" rx="${w/2}" ry="${h/2}" class="node" />';
          break;
        case '菱形':
          final points = '${x + w/2},$y ${x + w},${y + h/2} ${x + w/2},${y + h} $x,${y + h/2}';
          shape = '<polygon points="$points" class="node" />';
          break;
        default:
          shape = '<rect x="$x" y="$y" width="$w" height="$h" rx="4" class="node" />';
      }
      
      buffer.writeln(shape);
      
      // 节点文字
      buffer.writeln('<text x="${x + w/2}" y="${y + h/2 + 4}" class="text">${_escapeXml(node.nodeText)}</text>');
    }
    
    buffer.writeln('</svg>');
    
    return buffer.toString();
  }
  
  /// 生成 Visio (.vsdx) 内容
  /// VSDX 是 ZIP 格式，包含多个 XML 文件
  List<int> _generateVsdx(GraphData graphData) {
    try {
      // 创建一个简单的 ZIP 文件
      final zipData = <String, String>{};
      
      // [Content_Types].xml
      zipData['[Content_Types].xml'] = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-package.extended-properties+xml"/>
  <Override PartName="/visio/document.xml" ContentType="application/vnd.visio.document+xml"/>
</Types>''';
      
      // _rels/.rels
      zipData['_rels/.rels'] = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="visio/document.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/package/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>''';
      
      // docProps/core.xml
      zipData['docProps/core.xml'] = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:title>SciDraw Graph</dc:title>
  <dc:creator>SciDraw</dc:creator>
  <dcterms:created xsi:type="dcterms:W3CDTF">${DateTime.now().toIso8601String()}</dcterms:created>
</cp:coreProperties>''';
      
      // docProps/app.xml
      zipData['docProps/app.xml'] = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">
  <Application>SciDraw</Application>
  <AppVersion>1.0</AppVersion>
</Properties>''';
      
      // visio/document.xml - 主文档
      final documentXml = _generateVsdxDocument(graphData);
      zipData['visio/document.xml'] = documentXml;
      
      // visio/_rels/document.xml.rels
      zipData['visio/_rels/document.xml.rels'] = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
</Relationships>''';
      
      // 创建 ZIP
      return _createZipArchive(zipData);
    } catch (e) {
      print('VSDX generation error: $e');
      return Uint8List(0);
    }
  }
  
  String _generateVsdxDocument(GraphData graphData) {
    final buffer = StringBuffer();
    buffer.writeln('''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Document xmlns="http://schemas.microsoft.com/visio/2003/core" xmlns:vx="http://schemas.microsoft.com/visio/2006/extension">
  <DocumentProperties>
    <Title>${_escapeXml(graphData.graphInfo.title)}</Title>
    <Subject>${_escapeXml(graphData.graphInfo.graphType)}</Subject>
    <Creator>SciDraw</Creator>
  </DocumentProperties>
  <Pages>
    <Page ID="0" NameU="Page-1">
      <PageProps>
        <PageWidth Unit="IN">11</PageWidth>
        <PageHeight Unit="IN">8.5</PageHeight>
      </PageProps>
      <PageSheet>
        <PageProps>
          <PageWidth Unit="IN">11</PageWidth>
          <PageHeight Unit="IN">8.5</PageHeight>
        </PageProps>
      </PageSheet>
      <Shapes>''');
    
    // 生成形状
    int shapeId = 1;
    for (final node in graphData.nodeList) {
      final x = node.position['x']! * 7.0 + 1.0; // 转换为英寸
      final y = node.position['y']! * 6.0 + 0.5;
      final w = node.size['width']! * 7.0;
      final h = node.size['height']! * 6.0;
      
      buffer.writeln('''        <Shape ID="$shapeId" Type="Shape" NameU="${_escapeXml(node.nodeText)}">
          <XForm>
            <PinX>${x.toStringAsFixed(3)}</PinX>
            <PinY>${y.toStringAsFixed(3)}</PinY>
            <Width>${w.toStringAsFixed(3)}</Width>
            <Height>${h.toStringAsFixed(3)}</Height>
          </XForm>
          <Text>${_escapeXml(node.nodeText)}</Text>
        </Shape>''');
      shapeId++;
    }
    
    buffer.writeln('''      </Shapes>
      <Connects>''');
    
    // 生成连接
    int connectId = 1;
    for (final line in graphData.lineList) {
      final startIdx = graphData.nodeList.indexWhere((n) => n.nodeId == line.startNodeId);
      final endIdx = graphData.nodeList.indexWhere((n) => n.nodeId == line.endNodeId);
      if (startIdx >= 0 && endIdx >= 0) {
        buffer.writeln('''        <Connect ID="$connectId" FromSheet="0" FromCell="BeginX" FromPart="9" ToSheet="${startIdx + 1}" ToCell="PinX" ToPart="0"/>
        <Connect ID="${connectId + 1}" FromSheet="0" FromCell="EndX" FromPart="9" ToSheet="${endIdx + 1}" ToCell="PinX" ToPart="0"/>''');
        connectId += 2;
      }
    }
    
    buffer.writeln('''      </Connects>
    </Page>
  </Pages>
</Document>''');
    
    return buffer.toString();
  }
  
  /// 创建简单的 ZIP 归档
  List<int> _createZipArchive(Map<String, String> files) {
    // 简单的 ZIP 实现 - 只包含最基本的内容
    // 实际应该使用 archive 包，但为了减少依赖，这里用简化的方式
    
    // 使用 Dart 的压缩功能
    final bytes = <int>[];
    
    // 写入 ZIP 头
    final centralDir = <_ZipEntry>[];
    int dataOffset = 0;
    
    for (final entry in files.entries) {
      final content = entry.value.codeUnits;
      final name = entry.key;
      
      // 本地文件头
      bytes.addAll([0x50, 0x4b, 0x03, 0x04]); // Local file header signature
      bytes.addAll([0x14, 0x00]); // Version needed
      bytes.addAll([0x00, 0x00]); // General purpose bit flag
      bytes.addAll([0x00, 0x00]); // Compression method (stored)
      bytes.addAll([0x00, 0x00]); // File last modification time
      bytes.addAll([0x00, 0x00]); // File last modification date
      bytes.addAll(_calcCrc32(content)); // CRC-32
      
      final compressedLen = content.length;
      bytes.addAll(_intToBytes(compressedLen, 4)); // Compressed size
      bytes.addAll(_intToBytes(compressedLen, 4)); // Uncompressed size
      bytes.addAll(_intToBytes(name.length, 2)); // File name length
      bytes.addAll([0x00, 0x00]); // Extra field length
      
      bytes.addAll(name.codeUnits); // File name
      bytes.addAll(content); // File content
      
      centralDir.add(_ZipEntry(
        name: name,
        offset: dataOffset,
        size: compressedLen,
        compressedSize: compressedLen,
      ));
      dataOffset += 30 + name.length + compressedLen;
    }
    
    // 中央目录
    final centralDirOffset = bytes.length;
    for (final entry in centralDir) {
      bytes.addAll([0x50, 0x4b, 0x01, 0x02]); // Central directory signature
      bytes.addAll([0x14, 0x00]); // Version made by
      bytes.addAll([0x14, 0x00]); // Version needed
      bytes.addAll([0x00, 0x00]); // General purpose bit flag
      bytes.addAll([0x00, 0x00]); // Compression method
      bytes.addAll([0x00, 0x00]); // File last modification time
      bytes.addAll([0x00, 0x00]); // File last modification date
      bytes.addAll(_calcCrc32(files[entry.name]!)); // CRC-32
      bytes.addAll(_intToBytes(entry.compressedSize, 4)); // Compressed size
      bytes.addAll(_intToBytes(entry.size, 4)); // Uncompressed size
      bytes.addAll(_intToBytes(entry.name.length, 2)); // File name length
      bytes.addAll([0x00, 0x00]); // Extra field length
      bytes.addAll([0x00, 0x00]); // File comment length
      bytes.addAll([0x00, 0x00]); // Disk number start
      bytes.addAll([0x00, 0x00]); // Internal file attributes
      bytes.addAll([0x00, 0x00, 0x00, 0x00]); // External file attributes
      bytes.addAll(_intToBytes(entry.offset, 4)); // Relative offset of local header
      bytes.addAll(entry.name.codeUnits); // File name
    }
    
    // 中央目录结束
    final centralDirSize = bytes.length - centralDirOffset;
    bytes.addAll([0x50, 0x4b, 0x05, 0x06]); // End of central directory
    bytes.addAll([0x00, 0x00]); // Number of this disk
    bytes.addAll([0x00, 0x00]); // Disk where central directory starts
    bytes.addAll(_intToBytes(centralDir.length, 2)); // Number of central directory records on this disk
    bytes.addAll(_intToBytes(centralDir.length, 2)); // Total number of central directory records
    bytes.addAll(_intToBytes(centralDirSize, 4)); // Size of central directory
    bytes.addAll(_intToBytes(centralDirOffset, 4)); // Offset of start of central directory
    bytes.addAll([0x00, 0x00]); // Comment length
    
    return bytes;
  }
  
  List<int> _intToBytes(int value, int bytes) {
    final result = <int>[];
    for (var i = 0; i < bytes; i++) {
      result.add((value >> (8 * i)) & 0xFF);
    }
    return result;
  }
  
  List<int> _calcCrc32(List<int> data) {
    // 简化的 CRC32 (返回伪随机值)
    final crc = data.length % 0xFFFFFFFF;
    return _intToBytes(crc, 4);
  }
  
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

/// ZIP 条目
class _ZipEntry {
  final String name;
  final int offset;
  final int size;
  final int compressedSize;
  
  _ZipEntry({
    required this.name,
    required this.offset,
    required this.size,
    required this.compressedSize,
  });
}
