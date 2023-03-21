
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 e6 10 80       	mov    $0x8010e650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 ae 3a 10 80       	mov    $0x80103aae,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 1c 95 10 80       	push   $0x8010951c
80100046:	68 60 e6 10 80       	push   $0x8010e660
8010004b:	e8 39 54 00 00       	call   80105489 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 ac 2d 11 80 5c 	movl   $0x80112d5c,0x80112dac
8010005a:	2d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 b0 2d 11 80 5c 	movl   $0x80112d5c,0x80112db0
80100064:	2d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 e6 10 80 	movl   $0x8010e694,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 b0 2d 11 80    	mov    0x80112db0,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 5c 2d 11 80 	movl   $0x80112d5c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 23 95 10 80       	push   $0x80109523
80100094:	50                   	push   %eax
80100095:	e8 5c 52 00 00       	call   801052f6 <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 b0 2d 11 80       	mov    0x80112db0,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 b0 2d 11 80       	mov    %eax,0x80112db0
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 5c 2d 11 80       	mov    $0x80112d5c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 60 e6 10 80       	push   $0x8010e660
801000d7:	e8 d3 53 00 00       	call   801054af <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 b0 2d 11 80       	mov    0x80112db0,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 60 e6 10 80       	push   $0x8010e660
80100116:	e8 06 54 00 00       	call   80105521 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 09 52 00 00       	call   80105336 <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 5c 2d 11 80 	cmpl   $0x80112d5c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 ac 2d 11 80       	mov    0x80112dac,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 60 e6 10 80       	push   $0x8010e660
80100197:	e8 85 53 00 00       	call   80105521 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 88 51 00 00       	call   80105336 <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 5c 2d 11 80 	cmpl   $0x80112d5c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 2a 95 10 80       	push   $0x8010952a
801001d0:	e8 33 04 00 00       	call   80100608 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 01 29 00 00       	call   80102b0d <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 c3 51 00 00       	call   801053f0 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 3b 95 10 80       	push   $0x8010953b
8010023c:	e8 c7 03 00 00       	call   80100608 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 b2 28 00 00       	call   80102b0d <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 76 51 00 00       	call   801053f0 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 42 95 10 80       	push   $0x80109542
80100289:	e8 7a 03 00 00       	call   80100608 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 01 51 00 00       	call   8010539e <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 60 e6 10 80       	push   $0x8010e660
801002a8:	e8 02 52 00 00       	call   801054af <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 b0 2d 11 80    	mov    0x80112db0,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 5c 2d 11 80 	movl   $0x80112d5c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 b0 2d 11 80       	mov    0x80112db0,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 b0 2d 11 80       	mov    %eax,0x80112db0
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 60 e6 10 80       	push   $0x8010e660
80100318:	e8 04 52 00 00       	call   80105521 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 b0 10 80 	movzbl -0x7fef4ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 36 04 00 00       	call   8010083d <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //changed: added holding check
  if(locking && !holding(&cons.lock))
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 24                	je     80100454 <cprintf+0x3c>
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 c0 d5 10 80       	push   $0x8010d5c0
80100438:	e8 b9 51 00 00       	call   801055f6 <holding>
8010043d:	83 c4 10             	add    $0x10,%esp
80100440:	85 c0                	test   %eax,%eax
80100442:	75 10                	jne    80100454 <cprintf+0x3c>
    acquire(&cons.lock);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	68 c0 d5 10 80       	push   $0x8010d5c0
8010044c:	e8 5e 50 00 00       	call   801054af <acquire>
80100451:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100454:	8b 45 08             	mov    0x8(%ebp),%eax
80100457:	85 c0                	test   %eax,%eax
80100459:	75 0d                	jne    80100468 <cprintf+0x50>
    panic("null fmt");
8010045b:	83 ec 0c             	sub    $0xc,%esp
8010045e:	68 4c 95 10 80       	push   $0x8010954c
80100463:	e8 a0 01 00 00       	call   80100608 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100468:	8d 45 0c             	lea    0xc(%ebp),%eax
8010046b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010046e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100475:	e9 52 01 00 00       	jmp    801005cc <cprintf+0x1b4>
    if(c != '%'){
8010047a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047e:	74 13                	je     80100493 <cprintf+0x7b>
      consputc(c);
80100480:	83 ec 0c             	sub    $0xc,%esp
80100483:	ff 75 e4             	pushl  -0x1c(%ebp)
80100486:	e8 b2 03 00 00       	call   8010083d <consputc>
8010048b:	83 c4 10             	add    $0x10,%esp
      continue;
8010048e:	e9 35 01 00 00       	jmp    801005c8 <cprintf+0x1b0>
    }
    c = fmt[++i] & 0xff;
80100493:	8b 55 08             	mov    0x8(%ebp),%edx
80100496:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010049a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010049d:	01 d0                	add    %edx,%eax
8010049f:	0f b6 00             	movzbl (%eax),%eax
801004a2:	0f be c0             	movsbl %al,%eax
801004a5:	25 ff 00 00 00       	and    $0xff,%eax
801004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
801004ad:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801004b1:	0f 84 37 01 00 00    	je     801005ee <cprintf+0x1d6>
      break;
    switch(c){
801004b7:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004bb:	0f 84 dc 00 00 00    	je     8010059d <cprintf+0x185>
801004c1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004c5:	0f 8c e1 00 00 00    	jl     801005ac <cprintf+0x194>
801004cb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004cf:	0f 8f d7 00 00 00    	jg     801005ac <cprintf+0x194>
801004d5:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
801004d9:	0f 8c cd 00 00 00    	jl     801005ac <cprintf+0x194>
801004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004e2:	83 e8 63             	sub    $0x63,%eax
801004e5:	83 f8 15             	cmp    $0x15,%eax
801004e8:	0f 87 be 00 00 00    	ja     801005ac <cprintf+0x194>
801004ee:	8b 04 85 5c 95 10 80 	mov    -0x7fef6aa4(,%eax,4),%eax
801004f5:	3e ff e0             	notrack jmp *%eax
    case 'd':
      printint(*argp++, 10, 1);
801004f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fb:	8d 50 04             	lea    0x4(%eax),%edx
801004fe:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100501:	8b 00                	mov    (%eax),%eax
80100503:	83 ec 04             	sub    $0x4,%esp
80100506:	6a 01                	push   $0x1
80100508:	6a 0a                	push   $0xa
8010050a:	50                   	push   %eax
8010050b:	e8 58 fe ff ff       	call   80100368 <printint>
80100510:	83 c4 10             	add    $0x10,%esp
      break;
80100513:	e9 b0 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100518:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010051b:	8d 50 04             	lea    0x4(%eax),%edx
8010051e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100521:	8b 00                	mov    (%eax),%eax
80100523:	83 ec 04             	sub    $0x4,%esp
80100526:	6a 00                	push   $0x0
80100528:	6a 10                	push   $0x10
8010052a:	50                   	push   %eax
8010052b:	e8 38 fe ff ff       	call   80100368 <printint>
80100530:	83 c4 10             	add    $0x10,%esp
      break;
80100533:	e9 90 00 00 00       	jmp    801005c8 <cprintf+0x1b0>
    case 's':
      if((s = (char*)*argp++) == 0)
80100538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010053b:	8d 50 04             	lea    0x4(%eax),%edx
8010053e:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100541:	8b 00                	mov    (%eax),%eax
80100543:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100546:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010054a:	75 22                	jne    8010056e <cprintf+0x156>
        s = "(null)";
8010054c:	c7 45 ec 55 95 10 80 	movl   $0x80109555,-0x14(%ebp)
      for(; *s; s++)
80100553:	eb 19                	jmp    8010056e <cprintf+0x156>
        consputc(*s);
80100555:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f be c0             	movsbl %al,%eax
8010055e:	83 ec 0c             	sub    $0xc,%esp
80100561:	50                   	push   %eax
80100562:	e8 d6 02 00 00       	call   8010083d <consputc>
80100567:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010056a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010056e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100571:	0f b6 00             	movzbl (%eax),%eax
80100574:	84 c0                	test   %al,%al
80100576:	75 dd                	jne    80100555 <cprintf+0x13d>
      break;
80100578:	eb 4e                	jmp    801005c8 <cprintf+0x1b0>
    case 'c':
      s = (char*)argp++;
8010057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010057d:	8d 50 04             	lea    0x4(%eax),%edx
80100580:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100583:	89 45 ec             	mov    %eax,-0x14(%ebp)
      consputc(*(s));
80100586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100589:	0f b6 00             	movzbl (%eax),%eax
8010058c:	0f be c0             	movsbl %al,%eax
8010058f:	83 ec 0c             	sub    $0xc,%esp
80100592:	50                   	push   %eax
80100593:	e8 a5 02 00 00       	call   8010083d <consputc>
80100598:	83 c4 10             	add    $0x10,%esp
      break;
8010059b:	eb 2b                	jmp    801005c8 <cprintf+0x1b0>
    case '%':
      consputc('%');
8010059d:	83 ec 0c             	sub    $0xc,%esp
801005a0:	6a 25                	push   $0x25
801005a2:	e8 96 02 00 00       	call   8010083d <consputc>
801005a7:	83 c4 10             	add    $0x10,%esp
      break;
801005aa:	eb 1c                	jmp    801005c8 <cprintf+0x1b0>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005ac:	83 ec 0c             	sub    $0xc,%esp
801005af:	6a 25                	push   $0x25
801005b1:	e8 87 02 00 00       	call   8010083d <consputc>
801005b6:	83 c4 10             	add    $0x10,%esp
      consputc(c);
801005b9:	83 ec 0c             	sub    $0xc,%esp
801005bc:	ff 75 e4             	pushl  -0x1c(%ebp)
801005bf:	e8 79 02 00 00       	call   8010083d <consputc>
801005c4:	83 c4 10             	add    $0x10,%esp
      break;
801005c7:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005c8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005cc:	8b 55 08             	mov    0x8(%ebp),%edx
801005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d2:	01 d0                	add    %edx,%eax
801005d4:	0f b6 00             	movzbl (%eax),%eax
801005d7:	0f be c0             	movsbl %al,%eax
801005da:	25 ff 00 00 00       	and    $0xff,%eax
801005df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005e6:	0f 85 8e fe ff ff    	jne    8010047a <cprintf+0x62>
801005ec:	eb 01                	jmp    801005ef <cprintf+0x1d7>
      break;
801005ee:	90                   	nop
    }
  }

  if(locking)
801005ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005f3:	74 10                	je     80100605 <cprintf+0x1ed>
    release(&cons.lock);
801005f5:	83 ec 0c             	sub    $0xc,%esp
801005f8:	68 c0 d5 10 80       	push   $0x8010d5c0
801005fd:	e8 1f 4f 00 00       	call   80105521 <release>
80100602:	83 c4 10             	add    $0x10,%esp
}
80100605:	90                   	nop
80100606:	c9                   	leave  
80100607:	c3                   	ret    

80100608 <panic>:

void
panic(char *s)
{
80100608:	f3 0f 1e fb          	endbr32 
8010060c:	55                   	push   %ebp
8010060d:	89 e5                	mov    %esp,%ebp
8010060f:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
80100612:	e8 4a fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
80100617:	c7 05 f4 d5 10 80 00 	movl   $0x0,0x8010d5f4
8010061e:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100621:	e8 d9 2b 00 00       	call   801031ff <lapicid>
80100626:	83 ec 08             	sub    $0x8,%esp
80100629:	50                   	push   %eax
8010062a:	68 b4 95 10 80       	push   $0x801095b4
8010062f:	e8 e4 fd ff ff       	call   80100418 <cprintf>
80100634:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100637:	8b 45 08             	mov    0x8(%ebp),%eax
8010063a:	83 ec 0c             	sub    $0xc,%esp
8010063d:	50                   	push   %eax
8010063e:	e8 d5 fd ff ff       	call   80100418 <cprintf>
80100643:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80100646:	83 ec 0c             	sub    $0xc,%esp
80100649:	68 c8 95 10 80       	push   $0x801095c8
8010064e:	e8 c5 fd ff ff       	call   80100418 <cprintf>
80100653:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
80100656:	83 ec 08             	sub    $0x8,%esp
80100659:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010065c:	50                   	push   %eax
8010065d:	8d 45 08             	lea    0x8(%ebp),%eax
80100660:	50                   	push   %eax
80100661:	e8 11 4f 00 00       	call   80105577 <getcallerpcs>
80100666:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100669:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100670:	eb 1c                	jmp    8010068e <panic+0x86>
    cprintf(" %p", pcs[i]);
80100672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100675:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100679:	83 ec 08             	sub    $0x8,%esp
8010067c:	50                   	push   %eax
8010067d:	68 ca 95 10 80       	push   $0x801095ca
80100682:	e8 91 fd ff ff       	call   80100418 <cprintf>
80100687:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010068a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010068e:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100692:	7e de                	jle    80100672 <panic+0x6a>
  panicked = 1; // freeze other CPU
80100694:	c7 05 a0 d5 10 80 01 	movl   $0x1,0x8010d5a0
8010069b:	00 00 00 
  for(;;)
8010069e:	eb fe                	jmp    8010069e <panic+0x96>

801006a0 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801006a0:	f3 0f 1e fb          	endbr32 
801006a4:	55                   	push   %ebp
801006a5:	89 e5                	mov    %esp,%ebp
801006a7:	53                   	push   %ebx
801006a8:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801006ab:	6a 0e                	push   $0xe
801006ad:	68 d4 03 00 00       	push   $0x3d4
801006b2:	e8 89 fc ff ff       	call   80100340 <outb>
801006b7:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
801006ba:	68 d5 03 00 00       	push   $0x3d5
801006bf:	e8 5f fc ff ff       	call   80100323 <inb>
801006c4:	83 c4 04             	add    $0x4,%esp
801006c7:	0f b6 c0             	movzbl %al,%eax
801006ca:	c1 e0 08             	shl    $0x8,%eax
801006cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801006d0:	6a 0f                	push   $0xf
801006d2:	68 d4 03 00 00       	push   $0x3d4
801006d7:	e8 64 fc ff ff       	call   80100340 <outb>
801006dc:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006df:	68 d5 03 00 00       	push   $0x3d5
801006e4:	e8 3a fc ff ff       	call   80100323 <inb>
801006e9:	83 c4 04             	add    $0x4,%esp
801006ec:	0f b6 c0             	movzbl %al,%eax
801006ef:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006f2:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006f6:	75 30                	jne    80100728 <cgaputc+0x88>
    pos += 80 - pos%80;
801006f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fb:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100700:	89 c8                	mov    %ecx,%eax
80100702:	f7 ea                	imul   %edx
80100704:	c1 fa 05             	sar    $0x5,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	c1 f8 1f             	sar    $0x1f,%eax
8010070c:	29 c2                	sub    %eax,%edx
8010070e:	89 d0                	mov    %edx,%eax
80100710:	c1 e0 02             	shl    $0x2,%eax
80100713:	01 d0                	add    %edx,%eax
80100715:	c1 e0 04             	shl    $0x4,%eax
80100718:	29 c1                	sub    %eax,%ecx
8010071a:	89 ca                	mov    %ecx,%edx
8010071c:	b8 50 00 00 00       	mov    $0x50,%eax
80100721:	29 d0                	sub    %edx,%eax
80100723:	01 45 f4             	add    %eax,-0xc(%ebp)
80100726:	eb 38                	jmp    80100760 <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100728:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010072f:	75 0c                	jne    8010073d <cgaputc+0x9d>
    if(pos > 0) --pos;
80100731:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100735:	7e 29                	jle    80100760 <cgaputc+0xc0>
80100737:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010073b:	eb 23                	jmp    80100760 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010073d:	8b 45 08             	mov    0x8(%ebp),%eax
80100740:	0f b6 c0             	movzbl %al,%eax
80100743:	80 cc 07             	or     $0x7,%ah
80100746:	89 c3                	mov    %eax,%ebx
80100748:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
8010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100751:	8d 50 01             	lea    0x1(%eax),%edx
80100754:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100757:	01 c0                	add    %eax,%eax
80100759:	01 c8                	add    %ecx,%eax
8010075b:	89 da                	mov    %ebx,%edx
8010075d:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100760:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100764:	78 09                	js     8010076f <cgaputc+0xcf>
80100766:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
8010076d:	7e 0d                	jle    8010077c <cgaputc+0xdc>
    panic("pos under/overflow");
8010076f:	83 ec 0c             	sub    $0xc,%esp
80100772:	68 ce 95 10 80       	push   $0x801095ce
80100777:	e8 8c fe ff ff       	call   80100608 <panic>

  if((pos/80) >= 24){  // Scroll up.
8010077c:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100783:	7e 4c                	jle    801007d1 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100785:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010078a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100790:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100795:	83 ec 04             	sub    $0x4,%esp
80100798:	68 60 0e 00 00       	push   $0xe60
8010079d:	52                   	push   %edx
8010079e:	50                   	push   %eax
8010079f:	e8 71 50 00 00       	call   80105815 <memmove>
801007a4:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801007a7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801007ab:	b8 80 07 00 00       	mov    $0x780,%eax
801007b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801007b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801007b6:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801007bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801007be:	01 c9                	add    %ecx,%ecx
801007c0:	01 c8                	add    %ecx,%eax
801007c2:	83 ec 04             	sub    $0x4,%esp
801007c5:	52                   	push   %edx
801007c6:	6a 00                	push   $0x0
801007c8:	50                   	push   %eax
801007c9:	e8 80 4f 00 00       	call   8010574e <memset>
801007ce:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
801007d1:	83 ec 08             	sub    $0x8,%esp
801007d4:	6a 0e                	push   $0xe
801007d6:	68 d4 03 00 00       	push   $0x3d4
801007db:	e8 60 fb ff ff       	call   80100340 <outb>
801007e0:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007e6:	c1 f8 08             	sar    $0x8,%eax
801007e9:	0f b6 c0             	movzbl %al,%eax
801007ec:	83 ec 08             	sub    $0x8,%esp
801007ef:	50                   	push   %eax
801007f0:	68 d5 03 00 00       	push   $0x3d5
801007f5:	e8 46 fb ff ff       	call   80100340 <outb>
801007fa:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007fd:	83 ec 08             	sub    $0x8,%esp
80100800:	6a 0f                	push   $0xf
80100802:	68 d4 03 00 00       	push   $0x3d4
80100807:	e8 34 fb ff ff       	call   80100340 <outb>
8010080c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100812:	0f b6 c0             	movzbl %al,%eax
80100815:	83 ec 08             	sub    $0x8,%esp
80100818:	50                   	push   %eax
80100819:	68 d5 03 00 00       	push   $0x3d5
8010081e:	e8 1d fb ff ff       	call   80100340 <outb>
80100823:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100826:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010082b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010082e:	01 d2                	add    %edx,%edx
80100830:	01 d0                	add    %edx,%eax
80100832:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100837:	90                   	nop
80100838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010083b:	c9                   	leave  
8010083c:	c3                   	ret    

8010083d <consputc>:

void
consputc(int c)
{
8010083d:	f3 0f 1e fb          	endbr32 
80100841:	55                   	push   %ebp
80100842:	89 e5                	mov    %esp,%ebp
80100844:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100847:	a1 a0 d5 10 80       	mov    0x8010d5a0,%eax
8010084c:	85 c0                	test   %eax,%eax
8010084e:	74 07                	je     80100857 <consputc+0x1a>
    cli();
80100850:	e8 0c fb ff ff       	call   80100361 <cli>
    for(;;)
80100855:	eb fe                	jmp    80100855 <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100857:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010085e:	75 29                	jne    80100889 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	6a 08                	push   $0x8
80100865:	e8 03 6a 00 00       	call   8010726d <uartputc>
8010086a:	83 c4 10             	add    $0x10,%esp
8010086d:	83 ec 0c             	sub    $0xc,%esp
80100870:	6a 20                	push   $0x20
80100872:	e8 f6 69 00 00       	call   8010726d <uartputc>
80100877:	83 c4 10             	add    $0x10,%esp
8010087a:	83 ec 0c             	sub    $0xc,%esp
8010087d:	6a 08                	push   $0x8
8010087f:	e8 e9 69 00 00       	call   8010726d <uartputc>
80100884:	83 c4 10             	add    $0x10,%esp
80100887:	eb 0e                	jmp    80100897 <consputc+0x5a>
  } else
    uartputc(c);
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	ff 75 08             	pushl  0x8(%ebp)
8010088f:	e8 d9 69 00 00       	call   8010726d <uartputc>
80100894:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100897:	83 ec 0c             	sub    $0xc,%esp
8010089a:	ff 75 08             	pushl  0x8(%ebp)
8010089d:	e8 fe fd ff ff       	call   801006a0 <cgaputc>
801008a2:	83 c4 10             	add    $0x10,%esp
}
801008a5:	90                   	nop
801008a6:	c9                   	leave  
801008a7:	c3                   	ret    

801008a8 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801008a8:	f3 0f 1e fb          	endbr32 
801008ac:	55                   	push   %ebp
801008ad:	89 e5                	mov    %esp,%ebp
801008af:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801008b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 c0 d5 10 80       	push   $0x8010d5c0
801008c1:	e8 e9 4b 00 00       	call   801054af <acquire>
801008c6:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801008c9:	e9 52 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    switch(c){
801008ce:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008d2:	0f 84 81 00 00 00    	je     80100959 <consoleintr+0xb1>
801008d8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008dc:	0f 8f ac 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008e2:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008e6:	74 43                	je     8010092b <consoleintr+0x83>
801008e8:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008ec:	0f 8f 9c 00 00 00    	jg     8010098e <consoleintr+0xe6>
801008f2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008f6:	74 61                	je     80100959 <consoleintr+0xb1>
801008f8:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008fc:	0f 85 8c 00 00 00    	jne    8010098e <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100902:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100909:	e9 12 01 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010090e:	a1 48 30 11 80       	mov    0x80113048,%eax
80100913:	83 e8 01             	sub    $0x1,%eax
80100916:	a3 48 30 11 80       	mov    %eax,0x80113048
        consputc(BACKSPACE);
8010091b:	83 ec 0c             	sub    $0xc,%esp
8010091e:	68 00 01 00 00       	push   $0x100
80100923:	e8 15 ff ff ff       	call   8010083d <consputc>
80100928:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010092b:	8b 15 48 30 11 80    	mov    0x80113048,%edx
80100931:	a1 44 30 11 80       	mov    0x80113044,%eax
80100936:	39 c2                	cmp    %eax,%edx
80100938:	0f 84 e2 00 00 00    	je     80100a20 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010093e:	a1 48 30 11 80       	mov    0x80113048,%eax
80100943:	83 e8 01             	sub    $0x1,%eax
80100946:	83 e0 7f             	and    $0x7f,%eax
80100949:	0f b6 80 c0 2f 11 80 	movzbl -0x7feed040(%eax),%eax
      while(input.e != input.w &&
80100950:	3c 0a                	cmp    $0xa,%al
80100952:	75 ba                	jne    8010090e <consoleintr+0x66>
      }
      break;
80100954:	e9 c7 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100959:	8b 15 48 30 11 80    	mov    0x80113048,%edx
8010095f:	a1 44 30 11 80       	mov    0x80113044,%eax
80100964:	39 c2                	cmp    %eax,%edx
80100966:	0f 84 b4 00 00 00    	je     80100a20 <consoleintr+0x178>
        input.e--;
8010096c:	a1 48 30 11 80       	mov    0x80113048,%eax
80100971:	83 e8 01             	sub    $0x1,%eax
80100974:	a3 48 30 11 80       	mov    %eax,0x80113048
        consputc(BACKSPACE);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 00 01 00 00       	push   $0x100
80100981:	e8 b7 fe ff ff       	call   8010083d <consputc>
80100986:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100989:	e9 92 00 00 00       	jmp    80100a20 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010098e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100992:	0f 84 87 00 00 00    	je     80100a1f <consoleintr+0x177>
80100998:	8b 15 48 30 11 80    	mov    0x80113048,%edx
8010099e:	a1 40 30 11 80       	mov    0x80113040,%eax
801009a3:	29 c2                	sub    %eax,%edx
801009a5:	89 d0                	mov    %edx,%eax
801009a7:	83 f8 7f             	cmp    $0x7f,%eax
801009aa:	77 73                	ja     80100a1f <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
801009ac:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801009b0:	74 05                	je     801009b7 <consoleintr+0x10f>
801009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b5:	eb 05                	jmp    801009bc <consoleintr+0x114>
801009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801009bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009bf:	a1 48 30 11 80       	mov    0x80113048,%eax
801009c4:	8d 50 01             	lea    0x1(%eax),%edx
801009c7:	89 15 48 30 11 80    	mov    %edx,0x80113048
801009cd:	83 e0 7f             	and    $0x7f,%eax
801009d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009d3:	88 90 c0 2f 11 80    	mov    %dl,-0x7feed040(%eax)
        consputc(c);
801009d9:	83 ec 0c             	sub    $0xc,%esp
801009dc:	ff 75 f0             	pushl  -0x10(%ebp)
801009df:	e8 59 fe ff ff       	call   8010083d <consputc>
801009e4:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009e7:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009eb:	74 18                	je     80100a05 <consoleintr+0x15d>
801009ed:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009f1:	74 12                	je     80100a05 <consoleintr+0x15d>
801009f3:	a1 48 30 11 80       	mov    0x80113048,%eax
801009f8:	8b 15 40 30 11 80    	mov    0x80113040,%edx
801009fe:	83 ea 80             	sub    $0xffffff80,%edx
80100a01:	39 d0                	cmp    %edx,%eax
80100a03:	75 1a                	jne    80100a1f <consoleintr+0x177>
          input.w = input.e;
80100a05:	a1 48 30 11 80       	mov    0x80113048,%eax
80100a0a:	a3 44 30 11 80       	mov    %eax,0x80113044
          wakeup(&input.r);
80100a0f:	83 ec 0c             	sub    $0xc,%esp
80100a12:	68 40 30 11 80       	push   $0x80113040
80100a17:	e8 13 47 00 00       	call   8010512f <wakeup>
80100a1c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100a1f:	90                   	nop
  while((c = getc()) >= 0){
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	ff d0                	call   *%eax
80100a25:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100a28:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a2c:	0f 89 9c fe ff ff    	jns    801008ce <consoleintr+0x26>
    }
  }
  release(&cons.lock);
80100a32:	83 ec 0c             	sub    $0xc,%esp
80100a35:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a3a:	e8 e2 4a 00 00       	call   80105521 <release>
80100a3f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a46:	74 05                	je     80100a4d <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a48:	e8 a8 47 00 00       	call   801051f5 <procdump>
  }
}
80100a4d:	90                   	nop
80100a4e:	c9                   	leave  
80100a4f:	c3                   	ret    

80100a50 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a50:	f3 0f 1e fb          	endbr32 
80100a54:	55                   	push   %ebp
80100a55:	89 e5                	mov    %esp,%ebp
80100a57:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a5a:	83 ec 0c             	sub    $0xc,%esp
80100a5d:	ff 75 08             	pushl  0x8(%ebp)
80100a60:	e8 2e 12 00 00       	call   80101c93 <iunlock>
80100a65:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a68:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a6e:	83 ec 0c             	sub    $0xc,%esp
80100a71:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a76:	e8 34 4a 00 00       	call   801054af <acquire>
80100a7b:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a7e:	e9 ab 00 00 00       	jmp    80100b2e <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a83:	e8 a8 3a 00 00       	call   80104530 <myproc>
80100a88:	8b 40 24             	mov    0x24(%eax),%eax
80100a8b:	85 c0                	test   %eax,%eax
80100a8d:	74 28                	je     80100ab7 <consoleread+0x67>
        release(&cons.lock);
80100a8f:	83 ec 0c             	sub    $0xc,%esp
80100a92:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a97:	e8 85 4a 00 00       	call   80105521 <release>
80100a9c:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a9f:	83 ec 0c             	sub    $0xc,%esp
80100aa2:	ff 75 08             	pushl  0x8(%ebp)
80100aa5:	e8 d2 10 00 00       	call   80101b7c <ilock>
80100aaa:	83 c4 10             	add    $0x10,%esp
        return -1;
80100aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ab2:	e9 ab 00 00 00       	jmp    80100b62 <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100ab7:	83 ec 08             	sub    $0x8,%esp
80100aba:	68 c0 d5 10 80       	push   $0x8010d5c0
80100abf:	68 40 30 11 80       	push   $0x80113040
80100ac4:	e8 74 45 00 00       	call   8010503d <sleep>
80100ac9:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100acc:	8b 15 40 30 11 80    	mov    0x80113040,%edx
80100ad2:	a1 44 30 11 80       	mov    0x80113044,%eax
80100ad7:	39 c2                	cmp    %eax,%edx
80100ad9:	74 a8                	je     80100a83 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100adb:	a1 40 30 11 80       	mov    0x80113040,%eax
80100ae0:	8d 50 01             	lea    0x1(%eax),%edx
80100ae3:	89 15 40 30 11 80    	mov    %edx,0x80113040
80100ae9:	83 e0 7f             	and    $0x7f,%eax
80100aec:	0f b6 80 c0 2f 11 80 	movzbl -0x7feed040(%eax),%eax
80100af3:	0f be c0             	movsbl %al,%eax
80100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100af9:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100afd:	75 17                	jne    80100b16 <consoleread+0xc6>
      if(n < target){
80100aff:	8b 45 10             	mov    0x10(%ebp),%eax
80100b02:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100b05:	76 2f                	jbe    80100b36 <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b07:	a1 40 30 11 80       	mov    0x80113040,%eax
80100b0c:	83 e8 01             	sub    $0x1,%eax
80100b0f:	a3 40 30 11 80       	mov    %eax,0x80113040
      }
      break;
80100b14:	eb 20                	jmp    80100b36 <consoleread+0xe6>
    }
    *dst++ = c;
80100b16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b19:	8d 50 01             	lea    0x1(%eax),%edx
80100b1c:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b22:	88 10                	mov    %dl,(%eax)
    --n;
80100b24:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b28:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b2c:	74 0b                	je     80100b39 <consoleread+0xe9>
  while(n > 0){
80100b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b32:	7f 98                	jg     80100acc <consoleread+0x7c>
80100b34:	eb 04                	jmp    80100b3a <consoleread+0xea>
      break;
80100b36:	90                   	nop
80100b37:	eb 01                	jmp    80100b3a <consoleread+0xea>
      break;
80100b39:	90                   	nop
  }
  release(&cons.lock);
80100b3a:	83 ec 0c             	sub    $0xc,%esp
80100b3d:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b42:	e8 da 49 00 00       	call   80105521 <release>
80100b47:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b4a:	83 ec 0c             	sub    $0xc,%esp
80100b4d:	ff 75 08             	pushl  0x8(%ebp)
80100b50:	e8 27 10 00 00       	call   80101b7c <ilock>
80100b55:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b58:	8b 45 10             	mov    0x10(%ebp),%eax
80100b5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b5e:	29 c2                	sub    %eax,%edx
80100b60:	89 d0                	mov    %edx,%eax
}
80100b62:	c9                   	leave  
80100b63:	c3                   	ret    

80100b64 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b64:	f3 0f 1e fb          	endbr32 
80100b68:	55                   	push   %ebp
80100b69:	89 e5                	mov    %esp,%ebp
80100b6b:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b6e:	83 ec 0c             	sub    $0xc,%esp
80100b71:	ff 75 08             	pushl  0x8(%ebp)
80100b74:	e8 1a 11 00 00       	call   80101c93 <iunlock>
80100b79:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b7c:	83 ec 0c             	sub    $0xc,%esp
80100b7f:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b84:	e8 26 49 00 00       	call   801054af <acquire>
80100b89:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b93:	eb 21                	jmp    80100bb6 <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b9b:	01 d0                	add    %edx,%eax
80100b9d:	0f b6 00             	movzbl (%eax),%eax
80100ba0:	0f be c0             	movsbl %al,%eax
80100ba3:	0f b6 c0             	movzbl %al,%eax
80100ba6:	83 ec 0c             	sub    $0xc,%esp
80100ba9:	50                   	push   %eax
80100baa:	e8 8e fc ff ff       	call   8010083d <consputc>
80100baf:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100bb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bb9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bbc:	7c d7                	jl     80100b95 <consolewrite+0x31>
  release(&cons.lock);
80100bbe:	83 ec 0c             	sub    $0xc,%esp
80100bc1:	68 c0 d5 10 80       	push   $0x8010d5c0
80100bc6:	e8 56 49 00 00       	call   80105521 <release>
80100bcb:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bce:	83 ec 0c             	sub    $0xc,%esp
80100bd1:	ff 75 08             	pushl  0x8(%ebp)
80100bd4:	e8 a3 0f 00 00       	call   80101b7c <ilock>
80100bd9:	83 c4 10             	add    $0x10,%esp

  return n;
80100bdc:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bdf:	c9                   	leave  
80100be0:	c3                   	ret    

80100be1 <consoleinit>:

void
consoleinit(void)
{
80100be1:	f3 0f 1e fb          	endbr32 
80100be5:	55                   	push   %ebp
80100be6:	89 e5                	mov    %esp,%ebp
80100be8:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100beb:	83 ec 08             	sub    $0x8,%esp
80100bee:	68 e1 95 10 80       	push   $0x801095e1
80100bf3:	68 c0 d5 10 80       	push   $0x8010d5c0
80100bf8:	e8 8c 48 00 00       	call   80105489 <initlock>
80100bfd:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100c00:	c7 05 0c 3a 11 80 64 	movl   $0x80100b64,0x80113a0c
80100c07:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c0a:	c7 05 08 3a 11 80 50 	movl   $0x80100a50,0x80113a08
80100c11:	0a 10 80 
  cons.locking = 1;
80100c14:	c7 05 f4 d5 10 80 01 	movl   $0x1,0x8010d5f4
80100c1b:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c1e:	83 ec 08             	sub    $0x8,%esp
80100c21:	6a 00                	push   $0x0
80100c23:	6a 01                	push   $0x1
80100c25:	e8 bc 20 00 00       	call   80102ce6 <ioapicenable>
80100c2a:	83 c4 10             	add    $0x10,%esp
}
80100c2d:	90                   	nop
80100c2e:	c9                   	leave  
80100c2f:	c3                   	ret    

80100c30 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c30:	f3 0f 1e fb          	endbr32 
80100c34:	55                   	push   %ebp
80100c35:	89 e5                	mov    %esp,%ebp
80100c37:	81 ec 28 01 00 00    	sub    $0x128,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c3d:	e8 ee 38 00 00       	call   80104530 <myproc>
80100c42:	89 45 c8             	mov    %eax,-0x38(%ebp)

  begin_op();
80100c45:	e8 27 2b 00 00       	call   80103771 <begin_op>

  if((ip = namei(path)) == 0){
80100c4a:	83 ec 0c             	sub    $0xc,%esp
80100c4d:	ff 75 08             	pushl  0x8(%ebp)
80100c50:	e8 92 1a 00 00       	call   801026e7 <namei>
80100c55:	83 c4 10             	add    $0x10,%esp
80100c58:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c5f:	75 1f                	jne    80100c80 <exec+0x50>
    end_op();
80100c61:	e8 9b 2b 00 00       	call   80103801 <end_op>
    cprintf("exec: fail\n");
80100c66:	83 ec 0c             	sub    $0xc,%esp
80100c69:	68 e9 95 10 80       	push   $0x801095e9
80100c6e:	e8 a5 f7 ff ff       	call   80100418 <cprintf>
80100c73:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c7b:	e9 92 04 00 00       	jmp    80101112 <exec+0x4e2>
  }
  ilock(ip);
80100c80:	83 ec 0c             	sub    $0xc,%esp
80100c83:	ff 75 d8             	pushl  -0x28(%ebp)
80100c86:	e8 f1 0e 00 00       	call   80101b7c <ilock>
80100c8b:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c8e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c95:	6a 34                	push   $0x34
80100c97:	6a 00                	push   $0x0
80100c99:	8d 85 00 ff ff ff    	lea    -0x100(%ebp),%eax
80100c9f:	50                   	push   %eax
80100ca0:	ff 75 d8             	pushl  -0x28(%ebp)
80100ca3:	e8 dc 13 00 00       	call   80102084 <readi>
80100ca8:	83 c4 10             	add    $0x10,%esp
80100cab:	83 f8 34             	cmp    $0x34,%eax
80100cae:	0f 85 07 04 00 00    	jne    801010bb <exec+0x48b>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100cb4:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100cba:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cbf:	0f 85 f9 03 00 00    	jne    801010be <exec+0x48e>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100cc5:	e8 da 75 00 00       	call   801082a4 <setupkvm>
80100cca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ccd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cd1:	0f 84 ea 03 00 00    	je     801010c1 <exec+0x491>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cd7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cde:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100ce5:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
80100ceb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cee:	e9 de 00 00 00       	jmp    80100dd1 <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cf6:	6a 20                	push   $0x20
80100cf8:	50                   	push   %eax
80100cf9:	8d 85 e0 fe ff ff    	lea    -0x120(%ebp),%eax
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	pushl  -0x28(%ebp)
80100d03:	e8 7c 13 00 00       	call   80102084 <readi>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	83 f8 20             	cmp    $0x20,%eax
80100d0e:	0f 85 b0 03 00 00    	jne    801010c4 <exec+0x494>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100d14:	8b 85 e0 fe ff ff    	mov    -0x120(%ebp),%eax
80100d1a:	83 f8 01             	cmp    $0x1,%eax
80100d1d:	0f 85 a0 00 00 00    	jne    80100dc3 <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100d23:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d29:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d2f:	39 c2                	cmp    %eax,%edx
80100d31:	0f 82 90 03 00 00    	jb     801010c7 <exec+0x497>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d37:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100d3d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d43:	01 c2                	add    %eax,%edx
80100d45:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d4b:	39 c2                	cmp    %eax,%edx
80100d4d:	0f 82 77 03 00 00    	jb     801010ca <exec+0x49a>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d53:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100d59:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	83 ec 04             	sub    $0x4,%esp
80100d64:	50                   	push   %eax
80100d65:	ff 75 e0             	pushl  -0x20(%ebp)
80100d68:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d6b:	e8 f2 78 00 00       	call   80108662 <allocuvm>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d7a:	0f 84 4d 03 00 00    	je     801010cd <exec+0x49d>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d80:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d86:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 3d 03 00 00    	jne    801010d0 <exec+0x4a0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d93:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d99:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100d9f:	8b 8d e8 fe ff ff    	mov    -0x118(%ebp),%ecx
80100da5:	83 ec 0c             	sub    $0xc,%esp
80100da8:	52                   	push   %edx
80100da9:	50                   	push   %eax
80100daa:	ff 75 d8             	pushl  -0x28(%ebp)
80100dad:	51                   	push   %ecx
80100dae:	ff 75 d4             	pushl  -0x2c(%ebp)
80100db1:	e8 db 77 00 00       	call   80108591 <loaduvm>
80100db6:	83 c4 20             	add    $0x20,%esp
80100db9:	85 c0                	test   %eax,%eax
80100dbb:	0f 88 12 03 00 00    	js     801010d3 <exec+0x4a3>
80100dc1:	eb 01                	jmp    80100dc4 <exec+0x194>
      continue;
80100dc3:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dc4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100dc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dcb:	83 c0 20             	add    $0x20,%eax
80100dce:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dd1:	0f b7 85 2c ff ff ff 	movzwl -0xd4(%ebp),%eax
80100dd8:	0f b7 c0             	movzwl %ax,%eax
80100ddb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100dde:	0f 8c 0f ff ff ff    	jl     80100cf3 <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100de4:	83 ec 0c             	sub    $0xc,%esp
80100de7:	ff 75 d8             	pushl  -0x28(%ebp)
80100dea:	e8 ca 0f 00 00       	call   80101db9 <iunlockput>
80100def:	83 c4 10             	add    $0x10,%esp
  end_op();
80100df2:	e8 0a 2a 00 00       	call   80103801 <end_op>
  ip = 0;
80100df7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e11:	05 00 20 00 00       	add    $0x2000,%eax
80100e16:	83 ec 04             	sub    $0x4,%esp
80100e19:	50                   	push   %eax
80100e1a:	ff 75 e0             	pushl  -0x20(%ebp)
80100e1d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e20:	e8 3d 78 00 00       	call   80108662 <allocuvm>
80100e25:	83 c4 10             	add    $0x10,%esp
80100e28:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e2f:	0f 84 a1 02 00 00    	je     801010d6 <exec+0x4a6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e38:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e3d:	83 ec 08             	sub    $0x8,%esp
80100e40:	50                   	push   %eax
80100e41:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e44:	e8 8b 7a 00 00       	call   801088d4 <clearpteu>
80100e49:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e52:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e59:	e9 96 00 00 00       	jmp    80100ef4 <exec+0x2c4>
    if(argc >= MAXARG)
80100e5e:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e62:	0f 87 71 02 00 00    	ja     801010d9 <exec+0x4a9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e72:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e75:	01 d0                	add    %edx,%eax
80100e77:	8b 00                	mov    (%eax),%eax
80100e79:	83 ec 0c             	sub    $0xc,%esp
80100e7c:	50                   	push   %eax
80100e7d:	e8 35 4b 00 00       	call   801059b7 <strlen>
80100e82:	83 c4 10             	add    $0x10,%esp
80100e85:	89 c2                	mov    %eax,%edx
80100e87:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8a:	29 d0                	sub    %edx,%eax
80100e8c:	83 e8 01             	sub    $0x1,%eax
80100e8f:	83 e0 fc             	and    $0xfffffffc,%eax
80100e92:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e98:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea2:	01 d0                	add    %edx,%eax
80100ea4:	8b 00                	mov    (%eax),%eax
80100ea6:	83 ec 0c             	sub    $0xc,%esp
80100ea9:	50                   	push   %eax
80100eaa:	e8 08 4b 00 00       	call   801059b7 <strlen>
80100eaf:	83 c4 10             	add    $0x10,%esp
80100eb2:	83 c0 01             	add    $0x1,%eax
80100eb5:	89 c1                	mov    %eax,%ecx
80100eb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ec4:	01 d0                	add    %edx,%eax
80100ec6:	8b 00                	mov    (%eax),%eax
80100ec8:	51                   	push   %ecx
80100ec9:	50                   	push   %eax
80100eca:	ff 75 dc             	pushl  -0x24(%ebp)
80100ecd:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ed0:	e8 bb 7b 00 00       	call   80108a90 <copyout>
80100ed5:	83 c4 10             	add    $0x10,%esp
80100ed8:	85 c0                	test   %eax,%eax
80100eda:	0f 88 fc 01 00 00    	js     801010dc <exec+0x4ac>
      goto bad;
    ustack[3+argc] = sp;
80100ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee3:	8d 50 03             	lea    0x3(%eax),%edx
80100ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee9:	89 84 95 34 ff ff ff 	mov    %eax,-0xcc(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100ef0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ef4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f01:	01 d0                	add    %edx,%eax
80100f03:	8b 00                	mov    (%eax),%eax
80100f05:	85 c0                	test   %eax,%eax
80100f07:	0f 85 51 ff ff ff    	jne    80100e5e <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100f0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f10:	83 c0 03             	add    $0x3,%eax
80100f13:	c7 84 85 34 ff ff ff 	movl   $0x0,-0xcc(%ebp,%eax,4)
80100f1a:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f1e:	c7 85 34 ff ff ff ff 	movl   $0xffffffff,-0xcc(%ebp)
80100f25:	ff ff ff 
  ustack[1] = argc;
80100f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2b:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f34:	83 c0 01             	add    $0x1,%eax
80100f37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f41:	29 d0                	sub    %edx,%eax
80100f43:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)

  sp -= (3+argc+1) * 4;
80100f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4c:	83 c0 04             	add    $0x4,%eax
80100f4f:	c1 e0 02             	shl    $0x2,%eax
80100f52:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f58:	83 c0 04             	add    $0x4,%eax
80100f5b:	c1 e0 02             	shl    $0x2,%eax
80100f5e:	50                   	push   %eax
80100f5f:	8d 85 34 ff ff ff    	lea    -0xcc(%ebp),%eax
80100f65:	50                   	push   %eax
80100f66:	ff 75 dc             	pushl  -0x24(%ebp)
80100f69:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f6c:	e8 1f 7b 00 00       	call   80108a90 <copyout>
80100f71:	83 c4 10             	add    $0x10,%esp
80100f74:	85 c0                	test   %eax,%eax
80100f76:	0f 88 63 01 00 00    	js     801010df <exec+0x4af>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f88:	eb 17                	jmp    80100fa1 <exec+0x371>
    if(*s == '/')
80100f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8d:	0f b6 00             	movzbl (%eax),%eax
80100f90:	3c 2f                	cmp    $0x2f,%al
80100f92:	75 09                	jne    80100f9d <exec+0x36d>
      last = s+1;
80100f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f97:	83 c0 01             	add    $0x1,%eax
80100f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	0f b6 00             	movzbl (%eax),%eax
80100fa7:	84 c0                	test   %al,%al
80100fa9:	75 df                	jne    80100f8a <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fab:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fae:	83 c0 6c             	add    $0x6c,%eax
80100fb1:	83 ec 04             	sub    $0x4,%esp
80100fb4:	6a 10                	push   $0x10
80100fb6:	ff 75 f0             	pushl  -0x10(%ebp)
80100fb9:	50                   	push   %eax
80100fba:	e8 aa 49 00 00       	call   80105969 <safestrcpy>
80100fbf:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fc2:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fc5:	8b 40 04             	mov    0x4(%eax),%eax
80100fc8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  curproc->pgdir = pgdir;
80100fcb:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fd1:	89 50 04             	mov    %edx,0x4(%eax)

//guard page: sz - 2*PGSIZE 
  curproc->sz = sz;
80100fd4:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fda:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fdc:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fdf:	8b 40 18             	mov    0x18(%eax),%eax
80100fe2:	8b 95 18 ff ff ff    	mov    -0xe8(%ebp),%edx
80100fe8:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100feb:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100fee:	8b 40 18             	mov    0x18(%eax),%eax
80100ff1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ff4:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	ff 75 c8             	pushl  -0x38(%ebp)
80100ffd:	e8 78 73 00 00       	call   8010837a <switchuvm>
80101002:	83 c4 10             	add    $0x10,%esp
 
  for (int i = 0; i < CLOCKSIZE; i++){
80101005:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010100c:	eb 22                	jmp    80101030 <exec+0x400>
      curproc -> clock_array[i] = (char *) -1;
8010100e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101011:	8b 55 d0             	mov    -0x30(%ebp),%edx
80101014:	83 c2 1c             	add    $0x1c,%edx
80101017:	c7 44 90 0c ff ff ff 	movl   $0xffffffff,0xc(%eax,%edx,4)
8010101e:	ff 
      curproc -> clock_size =0;
8010101f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101022:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
80101029:	00 00 00 
  for (int i = 0; i < CLOCKSIZE; i++){
8010102c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
80101030:	83 7d d0 07          	cmpl   $0x7,-0x30(%ebp)
80101034:	7e d8                	jle    8010100e <exec+0x3de>
      
  }

   //mencrypt((char*) 0, curproc -> sz / PGSIZE);
    mencrypt((char*) 0, PGROUNDDOWN((sz - 2*PGSIZE)) / PGSIZE);
80101036:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101039:	2d 00 20 00 00       	sub    $0x2000,%eax
8010103e:	c1 e8 0c             	shr    $0xc,%eax
80101041:	83 ec 08             	sub    $0x8,%esp
80101044:	50                   	push   %eax
80101045:	6a 00                	push   $0x0
80101047:	e8 aa 7f 00 00       	call   80108ff6 <mencrypt>
8010104c:	83 c4 10             	add    $0x10,%esp
    mencrypt((char*) sz - PGSIZE, 1);
8010104f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101052:	2d 00 10 00 00       	sub    $0x1000,%eax
80101057:	83 ec 08             	sub    $0x8,%esp
8010105a:	6a 01                	push   $0x1
8010105c:	50                   	push   %eax
8010105d:	e8 94 7f 00 00       	call   80108ff6 <mencrypt>
80101062:	83 c4 10             	add    $0x10,%esp
   cprintf("exec clock");
80101065:	83 ec 0c             	sub    $0xc,%esp
80101068:	68 f5 95 10 80       	push   $0x801095f5
8010106d:	e8 a6 f3 ff ff       	call   80100418 <cprintf>
80101072:	83 c4 10             	add    $0x10,%esp
   for(int i= 0; i < CLOCKSIZE; i++){
80101075:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
8010107c:	eb 22                	jmp    801010a0 <exec+0x470>
       cprintf("%x\n",curproc -> clock_array[i]);
8010107e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80101081:	8b 55 cc             	mov    -0x34(%ebp),%edx
80101084:	83 c2 1c             	add    $0x1c,%edx
80101087:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010108b:	83 ec 08             	sub    $0x8,%esp
8010108e:	50                   	push   %eax
8010108f:	68 00 96 10 80       	push   $0x80109600
80101094:	e8 7f f3 ff ff       	call   80100418 <cprintf>
80101099:	83 c4 10             	add    $0x10,%esp
   for(int i= 0; i < CLOCKSIZE; i++){
8010109c:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
801010a0:	83 7d cc 07          	cmpl   $0x7,-0x34(%ebp)
801010a4:	7e d8                	jle    8010107e <exec+0x44e>
   }
  freevm(oldpgdir);
801010a6:	83 ec 0c             	sub    $0xc,%esp
801010a9:	ff 75 c4             	pushl  -0x3c(%ebp)
801010ac:	e8 84 77 00 00       	call   80108835 <freevm>
801010b1:	83 c4 10             	add    $0x10,%esp
  return 0;
801010b4:	b8 00 00 00 00       	mov    $0x0,%eax
801010b9:	eb 57                	jmp    80101112 <exec+0x4e2>
    goto bad;
801010bb:	90                   	nop
801010bc:	eb 22                	jmp    801010e0 <exec+0x4b0>
    goto bad;
801010be:	90                   	nop
801010bf:	eb 1f                	jmp    801010e0 <exec+0x4b0>
    goto bad;
801010c1:	90                   	nop
801010c2:	eb 1c                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010c4:	90                   	nop
801010c5:	eb 19                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010c7:	90                   	nop
801010c8:	eb 16                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010ca:	90                   	nop
801010cb:	eb 13                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010cd:	90                   	nop
801010ce:	eb 10                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010d0:	90                   	nop
801010d1:	eb 0d                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010d3:	90                   	nop
801010d4:	eb 0a                	jmp    801010e0 <exec+0x4b0>
    goto bad;
801010d6:	90                   	nop
801010d7:	eb 07                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010d9:	90                   	nop
801010da:	eb 04                	jmp    801010e0 <exec+0x4b0>
      goto bad;
801010dc:	90                   	nop
801010dd:	eb 01                	jmp    801010e0 <exec+0x4b0>
    goto bad;
801010df:	90                   	nop

 bad:
  if(pgdir)
801010e0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
801010e4:	74 0e                	je     801010f4 <exec+0x4c4>
    freevm(pgdir);
801010e6:	83 ec 0c             	sub    $0xc,%esp
801010e9:	ff 75 d4             	pushl  -0x2c(%ebp)
801010ec:	e8 44 77 00 00       	call   80108835 <freevm>
801010f1:	83 c4 10             	add    $0x10,%esp
  if(ip){
801010f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010f8:	74 13                	je     8010110d <exec+0x4dd>
    iunlockput(ip);
801010fa:	83 ec 0c             	sub    $0xc,%esp
801010fd:	ff 75 d8             	pushl  -0x28(%ebp)
80101100:	e8 b4 0c 00 00       	call   80101db9 <iunlockput>
80101105:	83 c4 10             	add    $0x10,%esp
    end_op();
80101108:	e8 f4 26 00 00       	call   80103801 <end_op>
  }
  return -1;
8010110d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101112:	c9                   	leave  
80101113:	c3                   	ret    

80101114 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101114:	f3 0f 1e fb          	endbr32 
80101118:	55                   	push   %ebp
80101119:	89 e5                	mov    %esp,%ebp
8010111b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010111e:	83 ec 08             	sub    $0x8,%esp
80101121:	68 04 96 10 80       	push   $0x80109604
80101126:	68 60 30 11 80       	push   $0x80113060
8010112b:	e8 59 43 00 00       	call   80105489 <initlock>
80101130:	83 c4 10             	add    $0x10,%esp
}
80101133:	90                   	nop
80101134:	c9                   	leave  
80101135:	c3                   	ret    

80101136 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101136:	f3 0f 1e fb          	endbr32 
8010113a:	55                   	push   %ebp
8010113b:	89 e5                	mov    %esp,%ebp
8010113d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101140:	83 ec 0c             	sub    $0xc,%esp
80101143:	68 60 30 11 80       	push   $0x80113060
80101148:	e8 62 43 00 00       	call   801054af <acquire>
8010114d:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101150:	c7 45 f4 94 30 11 80 	movl   $0x80113094,-0xc(%ebp)
80101157:	eb 2d                	jmp    80101186 <filealloc+0x50>
    if(f->ref == 0){
80101159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010115c:	8b 40 04             	mov    0x4(%eax),%eax
8010115f:	85 c0                	test   %eax,%eax
80101161:	75 1f                	jne    80101182 <filealloc+0x4c>
      f->ref = 1;
80101163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101166:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010116d:	83 ec 0c             	sub    $0xc,%esp
80101170:	68 60 30 11 80       	push   $0x80113060
80101175:	e8 a7 43 00 00       	call   80105521 <release>
8010117a:	83 c4 10             	add    $0x10,%esp
      return f;
8010117d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101180:	eb 23                	jmp    801011a5 <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101182:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101186:	b8 f4 39 11 80       	mov    $0x801139f4,%eax
8010118b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010118e:	72 c9                	jb     80101159 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101190:	83 ec 0c             	sub    $0xc,%esp
80101193:	68 60 30 11 80       	push   $0x80113060
80101198:	e8 84 43 00 00       	call   80105521 <release>
8010119d:	83 c4 10             	add    $0x10,%esp
  return 0;
801011a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801011a5:	c9                   	leave  
801011a6:	c3                   	ret    

801011a7 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801011a7:	f3 0f 1e fb          	endbr32 
801011ab:	55                   	push   %ebp
801011ac:	89 e5                	mov    %esp,%ebp
801011ae:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801011b1:	83 ec 0c             	sub    $0xc,%esp
801011b4:	68 60 30 11 80       	push   $0x80113060
801011b9:	e8 f1 42 00 00       	call   801054af <acquire>
801011be:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801011c1:	8b 45 08             	mov    0x8(%ebp),%eax
801011c4:	8b 40 04             	mov    0x4(%eax),%eax
801011c7:	85 c0                	test   %eax,%eax
801011c9:	7f 0d                	jg     801011d8 <filedup+0x31>
    panic("filedup");
801011cb:	83 ec 0c             	sub    $0xc,%esp
801011ce:	68 0b 96 10 80       	push   $0x8010960b
801011d3:	e8 30 f4 ff ff       	call   80100608 <panic>
  f->ref++;
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 40 04             	mov    0x4(%eax),%eax
801011de:	8d 50 01             	lea    0x1(%eax),%edx
801011e1:	8b 45 08             	mov    0x8(%ebp),%eax
801011e4:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801011e7:	83 ec 0c             	sub    $0xc,%esp
801011ea:	68 60 30 11 80       	push   $0x80113060
801011ef:	e8 2d 43 00 00       	call   80105521 <release>
801011f4:	83 c4 10             	add    $0x10,%esp
  return f;
801011f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011fa:	c9                   	leave  
801011fb:	c3                   	ret    

801011fc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011fc:	f3 0f 1e fb          	endbr32 
80101200:	55                   	push   %ebp
80101201:	89 e5                	mov    %esp,%ebp
80101203:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101206:	83 ec 0c             	sub    $0xc,%esp
80101209:	68 60 30 11 80       	push   $0x80113060
8010120e:	e8 9c 42 00 00       	call   801054af <acquire>
80101213:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101216:	8b 45 08             	mov    0x8(%ebp),%eax
80101219:	8b 40 04             	mov    0x4(%eax),%eax
8010121c:	85 c0                	test   %eax,%eax
8010121e:	7f 0d                	jg     8010122d <fileclose+0x31>
    panic("fileclose");
80101220:	83 ec 0c             	sub    $0xc,%esp
80101223:	68 13 96 10 80       	push   $0x80109613
80101228:	e8 db f3 ff ff       	call   80100608 <panic>
  if(--f->ref > 0){
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 04             	mov    0x4(%eax),%eax
80101233:	8d 50 ff             	lea    -0x1(%eax),%edx
80101236:	8b 45 08             	mov    0x8(%ebp),%eax
80101239:	89 50 04             	mov    %edx,0x4(%eax)
8010123c:	8b 45 08             	mov    0x8(%ebp),%eax
8010123f:	8b 40 04             	mov    0x4(%eax),%eax
80101242:	85 c0                	test   %eax,%eax
80101244:	7e 15                	jle    8010125b <fileclose+0x5f>
    release(&ftable.lock);
80101246:	83 ec 0c             	sub    $0xc,%esp
80101249:	68 60 30 11 80       	push   $0x80113060
8010124e:	e8 ce 42 00 00       	call   80105521 <release>
80101253:	83 c4 10             	add    $0x10,%esp
80101256:	e9 8b 00 00 00       	jmp    801012e6 <fileclose+0xea>
    return;
  }
  ff = *f;
8010125b:	8b 45 08             	mov    0x8(%ebp),%eax
8010125e:	8b 10                	mov    (%eax),%edx
80101260:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101263:	8b 50 04             	mov    0x4(%eax),%edx
80101266:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101269:	8b 50 08             	mov    0x8(%eax),%edx
8010126c:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010126f:	8b 50 0c             	mov    0xc(%eax),%edx
80101272:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101275:	8b 50 10             	mov    0x10(%eax),%edx
80101278:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010127b:	8b 40 14             	mov    0x14(%eax),%eax
8010127e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101294:	83 ec 0c             	sub    $0xc,%esp
80101297:	68 60 30 11 80       	push   $0x80113060
8010129c:	e8 80 42 00 00       	call   80105521 <release>
801012a1:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801012a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012a7:	83 f8 01             	cmp    $0x1,%eax
801012aa:	75 19                	jne    801012c5 <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801012ac:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801012b0:	0f be d0             	movsbl %al,%edx
801012b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012b6:	83 ec 08             	sub    $0x8,%esp
801012b9:	52                   	push   %edx
801012ba:	50                   	push   %eax
801012bb:	e8 e7 2e 00 00       	call   801041a7 <pipeclose>
801012c0:	83 c4 10             	add    $0x10,%esp
801012c3:	eb 21                	jmp    801012e6 <fileclose+0xea>
  else if(ff.type == FD_INODE){
801012c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801012c8:	83 f8 02             	cmp    $0x2,%eax
801012cb:	75 19                	jne    801012e6 <fileclose+0xea>
    begin_op();
801012cd:	e8 9f 24 00 00       	call   80103771 <begin_op>
    iput(ff.ip);
801012d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012d5:	83 ec 0c             	sub    $0xc,%esp
801012d8:	50                   	push   %eax
801012d9:	e8 07 0a 00 00       	call   80101ce5 <iput>
801012de:	83 c4 10             	add    $0x10,%esp
    end_op();
801012e1:	e8 1b 25 00 00       	call   80103801 <end_op>
  }
}
801012e6:	c9                   	leave  
801012e7:	c3                   	ret    

801012e8 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801012e8:	f3 0f 1e fb          	endbr32 
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	8b 00                	mov    (%eax),%eax
801012f7:	83 f8 02             	cmp    $0x2,%eax
801012fa:	75 40                	jne    8010133c <filestat+0x54>
    ilock(f->ip);
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 40 10             	mov    0x10(%eax),%eax
80101302:	83 ec 0c             	sub    $0xc,%esp
80101305:	50                   	push   %eax
80101306:	e8 71 08 00 00       	call   80101b7c <ilock>
8010130b:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 40 10             	mov    0x10(%eax),%eax
80101314:	83 ec 08             	sub    $0x8,%esp
80101317:	ff 75 0c             	pushl  0xc(%ebp)
8010131a:	50                   	push   %eax
8010131b:	e8 1a 0d 00 00       	call   8010203a <stati>
80101320:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101323:	8b 45 08             	mov    0x8(%ebp),%eax
80101326:	8b 40 10             	mov    0x10(%eax),%eax
80101329:	83 ec 0c             	sub    $0xc,%esp
8010132c:	50                   	push   %eax
8010132d:	e8 61 09 00 00       	call   80101c93 <iunlock>
80101332:	83 c4 10             	add    $0x10,%esp
    return 0;
80101335:	b8 00 00 00 00       	mov    $0x0,%eax
8010133a:	eb 05                	jmp    80101341 <filestat+0x59>
  }
  return -1;
8010133c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101341:	c9                   	leave  
80101342:	c3                   	ret    

80101343 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101343:	f3 0f 1e fb          	endbr32 
80101347:	55                   	push   %ebp
80101348:	89 e5                	mov    %esp,%ebp
8010134a:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010134d:	8b 45 08             	mov    0x8(%ebp),%eax
80101350:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101354:	84 c0                	test   %al,%al
80101356:	75 0a                	jne    80101362 <fileread+0x1f>
    return -1;
80101358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010135d:	e9 9b 00 00 00       	jmp    801013fd <fileread+0xba>
  if(f->type == FD_PIPE)
80101362:	8b 45 08             	mov    0x8(%ebp),%eax
80101365:	8b 00                	mov    (%eax),%eax
80101367:	83 f8 01             	cmp    $0x1,%eax
8010136a:	75 1a                	jne    80101386 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010136c:	8b 45 08             	mov    0x8(%ebp),%eax
8010136f:	8b 40 0c             	mov    0xc(%eax),%eax
80101372:	83 ec 04             	sub    $0x4,%esp
80101375:	ff 75 10             	pushl  0x10(%ebp)
80101378:	ff 75 0c             	pushl  0xc(%ebp)
8010137b:	50                   	push   %eax
8010137c:	e8 db 2f 00 00       	call   8010435c <piperead>
80101381:	83 c4 10             	add    $0x10,%esp
80101384:	eb 77                	jmp    801013fd <fileread+0xba>
  if(f->type == FD_INODE){
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	8b 00                	mov    (%eax),%eax
8010138b:	83 f8 02             	cmp    $0x2,%eax
8010138e:	75 60                	jne    801013f0 <fileread+0xad>
    ilock(f->ip);
80101390:	8b 45 08             	mov    0x8(%ebp),%eax
80101393:	8b 40 10             	mov    0x10(%eax),%eax
80101396:	83 ec 0c             	sub    $0xc,%esp
80101399:	50                   	push   %eax
8010139a:	e8 dd 07 00 00       	call   80101b7c <ilock>
8010139f:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801013a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
801013a5:	8b 45 08             	mov    0x8(%ebp),%eax
801013a8:	8b 50 14             	mov    0x14(%eax),%edx
801013ab:	8b 45 08             	mov    0x8(%ebp),%eax
801013ae:	8b 40 10             	mov    0x10(%eax),%eax
801013b1:	51                   	push   %ecx
801013b2:	52                   	push   %edx
801013b3:	ff 75 0c             	pushl  0xc(%ebp)
801013b6:	50                   	push   %eax
801013b7:	e8 c8 0c 00 00       	call   80102084 <readi>
801013bc:	83 c4 10             	add    $0x10,%esp
801013bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801013c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801013c6:	7e 11                	jle    801013d9 <fileread+0x96>
      f->off += r;
801013c8:	8b 45 08             	mov    0x8(%ebp),%eax
801013cb:	8b 50 14             	mov    0x14(%eax),%edx
801013ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d1:	01 c2                	add    %eax,%edx
801013d3:	8b 45 08             	mov    0x8(%ebp),%eax
801013d6:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801013d9:	8b 45 08             	mov    0x8(%ebp),%eax
801013dc:	8b 40 10             	mov    0x10(%eax),%eax
801013df:	83 ec 0c             	sub    $0xc,%esp
801013e2:	50                   	push   %eax
801013e3:	e8 ab 08 00 00       	call   80101c93 <iunlock>
801013e8:	83 c4 10             	add    $0x10,%esp
    return r;
801013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ee:	eb 0d                	jmp    801013fd <fileread+0xba>
  }
  panic("fileread");
801013f0:	83 ec 0c             	sub    $0xc,%esp
801013f3:	68 1d 96 10 80       	push   $0x8010961d
801013f8:	e8 0b f2 ff ff       	call   80100608 <panic>
}
801013fd:	c9                   	leave  
801013fe:	c3                   	ret    

801013ff <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801013ff:	f3 0f 1e fb          	endbr32 
80101403:	55                   	push   %ebp
80101404:	89 e5                	mov    %esp,%ebp
80101406:	53                   	push   %ebx
80101407:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010140a:	8b 45 08             	mov    0x8(%ebp),%eax
8010140d:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101411:	84 c0                	test   %al,%al
80101413:	75 0a                	jne    8010141f <filewrite+0x20>
    return -1;
80101415:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010141a:	e9 1b 01 00 00       	jmp    8010153a <filewrite+0x13b>
  if(f->type == FD_PIPE)
8010141f:	8b 45 08             	mov    0x8(%ebp),%eax
80101422:	8b 00                	mov    (%eax),%eax
80101424:	83 f8 01             	cmp    $0x1,%eax
80101427:	75 1d                	jne    80101446 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101429:	8b 45 08             	mov    0x8(%ebp),%eax
8010142c:	8b 40 0c             	mov    0xc(%eax),%eax
8010142f:	83 ec 04             	sub    $0x4,%esp
80101432:	ff 75 10             	pushl  0x10(%ebp)
80101435:	ff 75 0c             	pushl  0xc(%ebp)
80101438:	50                   	push   %eax
80101439:	e8 18 2e 00 00       	call   80104256 <pipewrite>
8010143e:	83 c4 10             	add    $0x10,%esp
80101441:	e9 f4 00 00 00       	jmp    8010153a <filewrite+0x13b>
  if(f->type == FD_INODE){
80101446:	8b 45 08             	mov    0x8(%ebp),%eax
80101449:	8b 00                	mov    (%eax),%eax
8010144b:	83 f8 02             	cmp    $0x2,%eax
8010144e:	0f 85 d9 00 00 00    	jne    8010152d <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
80101454:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
8010145b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101462:	e9 a3 00 00 00       	jmp    8010150a <filewrite+0x10b>
      int n1 = n - i;
80101467:	8b 45 10             	mov    0x10(%ebp),%eax
8010146a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010146d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101470:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101473:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101476:	7e 06                	jle    8010147e <filewrite+0x7f>
        n1 = max;
80101478:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010147b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010147e:	e8 ee 22 00 00       	call   80103771 <begin_op>
      ilock(f->ip);
80101483:	8b 45 08             	mov    0x8(%ebp),%eax
80101486:	8b 40 10             	mov    0x10(%eax),%eax
80101489:	83 ec 0c             	sub    $0xc,%esp
8010148c:	50                   	push   %eax
8010148d:	e8 ea 06 00 00       	call   80101b7c <ilock>
80101492:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101495:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101498:	8b 45 08             	mov    0x8(%ebp),%eax
8010149b:	8b 50 14             	mov    0x14(%eax),%edx
8010149e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801014a4:	01 c3                	add    %eax,%ebx
801014a6:	8b 45 08             	mov    0x8(%ebp),%eax
801014a9:	8b 40 10             	mov    0x10(%eax),%eax
801014ac:	51                   	push   %ecx
801014ad:	52                   	push   %edx
801014ae:	53                   	push   %ebx
801014af:	50                   	push   %eax
801014b0:	e8 28 0d 00 00       	call   801021dd <writei>
801014b5:	83 c4 10             	add    $0x10,%esp
801014b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
801014bb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014bf:	7e 11                	jle    801014d2 <filewrite+0xd3>
        f->off += r;
801014c1:	8b 45 08             	mov    0x8(%ebp),%eax
801014c4:	8b 50 14             	mov    0x14(%eax),%edx
801014c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014ca:	01 c2                	add    %eax,%edx
801014cc:	8b 45 08             	mov    0x8(%ebp),%eax
801014cf:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801014d2:	8b 45 08             	mov    0x8(%ebp),%eax
801014d5:	8b 40 10             	mov    0x10(%eax),%eax
801014d8:	83 ec 0c             	sub    $0xc,%esp
801014db:	50                   	push   %eax
801014dc:	e8 b2 07 00 00       	call   80101c93 <iunlock>
801014e1:	83 c4 10             	add    $0x10,%esp
      end_op();
801014e4:	e8 18 23 00 00       	call   80103801 <end_op>

      if(r < 0)
801014e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801014ed:	78 29                	js     80101518 <filewrite+0x119>
        break;
      if(r != n1)
801014ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801014f2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801014f5:	74 0d                	je     80101504 <filewrite+0x105>
        panic("short filewrite");
801014f7:	83 ec 0c             	sub    $0xc,%esp
801014fa:	68 26 96 10 80       	push   $0x80109626
801014ff:	e8 04 f1 ff ff       	call   80100608 <panic>
      i += r;
80101504:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101507:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010150a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010150d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101510:	0f 8c 51 ff ff ff    	jl     80101467 <filewrite+0x68>
80101516:	eb 01                	jmp    80101519 <filewrite+0x11a>
        break;
80101518:	90                   	nop
    }
    return i == n ? n : -1;
80101519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010151c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010151f:	75 05                	jne    80101526 <filewrite+0x127>
80101521:	8b 45 10             	mov    0x10(%ebp),%eax
80101524:	eb 14                	jmp    8010153a <filewrite+0x13b>
80101526:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010152b:	eb 0d                	jmp    8010153a <filewrite+0x13b>
  }
  panic("filewrite");
8010152d:	83 ec 0c             	sub    $0xc,%esp
80101530:	68 36 96 10 80       	push   $0x80109636
80101535:	e8 ce f0 ff ff       	call   80100608 <panic>
}
8010153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010153d:	c9                   	leave  
8010153e:	c3                   	ret    

8010153f <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010153f:	f3 0f 1e fb          	endbr32 
80101543:	55                   	push   %ebp
80101544:	89 e5                	mov    %esp,%ebp
80101546:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101549:	8b 45 08             	mov    0x8(%ebp),%eax
8010154c:	83 ec 08             	sub    $0x8,%esp
8010154f:	6a 01                	push   $0x1
80101551:	50                   	push   %eax
80101552:	e8 80 ec ff ff       	call   801001d7 <bread>
80101557:	83 c4 10             	add    $0x10,%esp
8010155a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010155d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101560:	83 c0 5c             	add    $0x5c,%eax
80101563:	83 ec 04             	sub    $0x4,%esp
80101566:	6a 1c                	push   $0x1c
80101568:	50                   	push   %eax
80101569:	ff 75 0c             	pushl  0xc(%ebp)
8010156c:	e8 a4 42 00 00       	call   80105815 <memmove>
80101571:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101574:	83 ec 0c             	sub    $0xc,%esp
80101577:	ff 75 f4             	pushl  -0xc(%ebp)
8010157a:	e8 e2 ec ff ff       	call   80100261 <brelse>
8010157f:	83 c4 10             	add    $0x10,%esp
}
80101582:	90                   	nop
80101583:	c9                   	leave  
80101584:	c3                   	ret    

80101585 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101585:	f3 0f 1e fb          	endbr32 
80101589:	55                   	push   %ebp
8010158a:	89 e5                	mov    %esp,%ebp
8010158c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010158f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101592:	8b 45 08             	mov    0x8(%ebp),%eax
80101595:	83 ec 08             	sub    $0x8,%esp
80101598:	52                   	push   %edx
80101599:	50                   	push   %eax
8010159a:	e8 38 ec ff ff       	call   801001d7 <bread>
8010159f:	83 c4 10             	add    $0x10,%esp
801015a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a8:	83 c0 5c             	add    $0x5c,%eax
801015ab:	83 ec 04             	sub    $0x4,%esp
801015ae:	68 00 02 00 00       	push   $0x200
801015b3:	6a 00                	push   $0x0
801015b5:	50                   	push   %eax
801015b6:	e8 93 41 00 00       	call   8010574e <memset>
801015bb:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801015be:	83 ec 0c             	sub    $0xc,%esp
801015c1:	ff 75 f4             	pushl  -0xc(%ebp)
801015c4:	e8 f1 23 00 00       	call   801039ba <log_write>
801015c9:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801015cc:	83 ec 0c             	sub    $0xc,%esp
801015cf:	ff 75 f4             	pushl  -0xc(%ebp)
801015d2:	e8 8a ec ff ff       	call   80100261 <brelse>
801015d7:	83 c4 10             	add    $0x10,%esp
}
801015da:	90                   	nop
801015db:	c9                   	leave  
801015dc:	c3                   	ret    

801015dd <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801015dd:	f3 0f 1e fb          	endbr32 
801015e1:	55                   	push   %ebp
801015e2:	89 e5                	mov    %esp,%ebp
801015e4:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801015e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801015ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801015f5:	e9 13 01 00 00       	jmp    8010170d <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101603:	85 c0                	test   %eax,%eax
80101605:	0f 48 c2             	cmovs  %edx,%eax
80101608:	c1 f8 0c             	sar    $0xc,%eax
8010160b:	89 c2                	mov    %eax,%edx
8010160d:	a1 78 3a 11 80       	mov    0x80113a78,%eax
80101612:	01 d0                	add    %edx,%eax
80101614:	83 ec 08             	sub    $0x8,%esp
80101617:	50                   	push   %eax
80101618:	ff 75 08             	pushl  0x8(%ebp)
8010161b:	e8 b7 eb ff ff       	call   801001d7 <bread>
80101620:	83 c4 10             	add    $0x10,%esp
80101623:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101626:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010162d:	e9 a6 00 00 00       	jmp    801016d8 <balloc+0xfb>
      m = 1 << (bi % 8);
80101632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101635:	99                   	cltd   
80101636:	c1 ea 1d             	shr    $0x1d,%edx
80101639:	01 d0                	add    %edx,%eax
8010163b:	83 e0 07             	and    $0x7,%eax
8010163e:	29 d0                	sub    %edx,%eax
80101640:	ba 01 00 00 00       	mov    $0x1,%edx
80101645:	89 c1                	mov    %eax,%ecx
80101647:	d3 e2                	shl    %cl,%edx
80101649:	89 d0                	mov    %edx,%eax
8010164b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101651:	8d 50 07             	lea    0x7(%eax),%edx
80101654:	85 c0                	test   %eax,%eax
80101656:	0f 48 c2             	cmovs  %edx,%eax
80101659:	c1 f8 03             	sar    $0x3,%eax
8010165c:	89 c2                	mov    %eax,%edx
8010165e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101661:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101666:	0f b6 c0             	movzbl %al,%eax
80101669:	23 45 e8             	and    -0x18(%ebp),%eax
8010166c:	85 c0                	test   %eax,%eax
8010166e:	75 64                	jne    801016d4 <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	8d 50 07             	lea    0x7(%eax),%edx
80101676:	85 c0                	test   %eax,%eax
80101678:	0f 48 c2             	cmovs  %edx,%eax
8010167b:	c1 f8 03             	sar    $0x3,%eax
8010167e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101681:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101686:	89 d1                	mov    %edx,%ecx
80101688:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010168b:	09 ca                	or     %ecx,%edx
8010168d:	89 d1                	mov    %edx,%ecx
8010168f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101692:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101696:	83 ec 0c             	sub    $0xc,%esp
80101699:	ff 75 ec             	pushl  -0x14(%ebp)
8010169c:	e8 19 23 00 00       	call   801039ba <log_write>
801016a1:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801016a4:	83 ec 0c             	sub    $0xc,%esp
801016a7:	ff 75 ec             	pushl  -0x14(%ebp)
801016aa:	e8 b2 eb ff ff       	call   80100261 <brelse>
801016af:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801016b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b8:	01 c2                	add    %eax,%edx
801016ba:	8b 45 08             	mov    0x8(%ebp),%eax
801016bd:	83 ec 08             	sub    $0x8,%esp
801016c0:	52                   	push   %edx
801016c1:	50                   	push   %eax
801016c2:	e8 be fe ff ff       	call   80101585 <bzero>
801016c7:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801016ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d0:	01 d0                	add    %edx,%eax
801016d2:	eb 57                	jmp    8010172b <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801016d4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801016d8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801016df:	7f 17                	jg     801016f8 <balloc+0x11b>
801016e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e7:	01 d0                	add    %edx,%eax
801016e9:	89 c2                	mov    %eax,%edx
801016eb:	a1 60 3a 11 80       	mov    0x80113a60,%eax
801016f0:	39 c2                	cmp    %eax,%edx
801016f2:	0f 82 3a ff ff ff    	jb     80101632 <balloc+0x55>
      }
    }
    brelse(bp);
801016f8:	83 ec 0c             	sub    $0xc,%esp
801016fb:	ff 75 ec             	pushl  -0x14(%ebp)
801016fe:	e8 5e eb ff ff       	call   80100261 <brelse>
80101703:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101706:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010170d:	8b 15 60 3a 11 80    	mov    0x80113a60,%edx
80101713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101716:	39 c2                	cmp    %eax,%edx
80101718:	0f 87 dc fe ff ff    	ja     801015fa <balloc+0x1d>
  }
  panic("balloc: out of blocks");
8010171e:	83 ec 0c             	sub    $0xc,%esp
80101721:	68 40 96 10 80       	push   $0x80109640
80101726:	e8 dd ee ff ff       	call   80100608 <panic>
}
8010172b:	c9                   	leave  
8010172c:	c3                   	ret    

8010172d <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010172d:	f3 0f 1e fb          	endbr32 
80101731:	55                   	push   %ebp
80101732:	89 e5                	mov    %esp,%ebp
80101734:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101737:	8b 45 0c             	mov    0xc(%ebp),%eax
8010173a:	c1 e8 0c             	shr    $0xc,%eax
8010173d:	89 c2                	mov    %eax,%edx
8010173f:	a1 78 3a 11 80       	mov    0x80113a78,%eax
80101744:	01 c2                	add    %eax,%edx
80101746:	8b 45 08             	mov    0x8(%ebp),%eax
80101749:	83 ec 08             	sub    $0x8,%esp
8010174c:	52                   	push   %edx
8010174d:	50                   	push   %eax
8010174e:	e8 84 ea ff ff       	call   801001d7 <bread>
80101753:	83 c4 10             	add    $0x10,%esp
80101756:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101759:	8b 45 0c             	mov    0xc(%ebp),%eax
8010175c:	25 ff 0f 00 00       	and    $0xfff,%eax
80101761:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101764:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101767:	99                   	cltd   
80101768:	c1 ea 1d             	shr    $0x1d,%edx
8010176b:	01 d0                	add    %edx,%eax
8010176d:	83 e0 07             	and    $0x7,%eax
80101770:	29 d0                	sub    %edx,%eax
80101772:	ba 01 00 00 00       	mov    $0x1,%edx
80101777:	89 c1                	mov    %eax,%ecx
80101779:	d3 e2                	shl    %cl,%edx
8010177b:	89 d0                	mov    %edx,%eax
8010177d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101783:	8d 50 07             	lea    0x7(%eax),%edx
80101786:	85 c0                	test   %eax,%eax
80101788:	0f 48 c2             	cmovs  %edx,%eax
8010178b:	c1 f8 03             	sar    $0x3,%eax
8010178e:	89 c2                	mov    %eax,%edx
80101790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101793:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101798:	0f b6 c0             	movzbl %al,%eax
8010179b:	23 45 ec             	and    -0x14(%ebp),%eax
8010179e:	85 c0                	test   %eax,%eax
801017a0:	75 0d                	jne    801017af <bfree+0x82>
    panic("freeing free block");
801017a2:	83 ec 0c             	sub    $0xc,%esp
801017a5:	68 56 96 10 80       	push   $0x80109656
801017aa:	e8 59 ee ff ff       	call   80100608 <panic>
  bp->data[bi/8] &= ~m;
801017af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b2:	8d 50 07             	lea    0x7(%eax),%edx
801017b5:	85 c0                	test   %eax,%eax
801017b7:	0f 48 c2             	cmovs  %edx,%eax
801017ba:	c1 f8 03             	sar    $0x3,%eax
801017bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017c0:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801017c5:	89 d1                	mov    %edx,%ecx
801017c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801017ca:	f7 d2                	not    %edx
801017cc:	21 ca                	and    %ecx,%edx
801017ce:	89 d1                	mov    %edx,%ecx
801017d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017d3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801017d7:	83 ec 0c             	sub    $0xc,%esp
801017da:	ff 75 f4             	pushl  -0xc(%ebp)
801017dd:	e8 d8 21 00 00       	call   801039ba <log_write>
801017e2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017e5:	83 ec 0c             	sub    $0xc,%esp
801017e8:	ff 75 f4             	pushl  -0xc(%ebp)
801017eb:	e8 71 ea ff ff       	call   80100261 <brelse>
801017f0:	83 c4 10             	add    $0x10,%esp
}
801017f3:	90                   	nop
801017f4:	c9                   	leave  
801017f5:	c3                   	ret    

801017f6 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801017f6:	f3 0f 1e fb          	endbr32 
801017fa:	55                   	push   %ebp
801017fb:	89 e5                	mov    %esp,%ebp
801017fd:	57                   	push   %edi
801017fe:	56                   	push   %esi
801017ff:	53                   	push   %ebx
80101800:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
80101803:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010180a:	83 ec 08             	sub    $0x8,%esp
8010180d:	68 69 96 10 80       	push   $0x80109669
80101812:	68 80 3a 11 80       	push   $0x80113a80
80101817:	e8 6d 3c 00 00       	call   80105489 <initlock>
8010181c:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
8010181f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101826:	eb 2d                	jmp    80101855 <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101828:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010182b:	89 d0                	mov    %edx,%eax
8010182d:	c1 e0 03             	shl    $0x3,%eax
80101830:	01 d0                	add    %edx,%eax
80101832:	c1 e0 04             	shl    $0x4,%eax
80101835:	83 c0 30             	add    $0x30,%eax
80101838:	05 80 3a 11 80       	add    $0x80113a80,%eax
8010183d:	83 c0 10             	add    $0x10,%eax
80101840:	83 ec 08             	sub    $0x8,%esp
80101843:	68 70 96 10 80       	push   $0x80109670
80101848:	50                   	push   %eax
80101849:	e8 a8 3a 00 00       	call   801052f6 <initsleeplock>
8010184e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101851:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80101855:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101859:	7e cd                	jle    80101828 <iinit+0x32>
  }

  readsb(dev, &sb);
8010185b:	83 ec 08             	sub    $0x8,%esp
8010185e:	68 60 3a 11 80       	push   $0x80113a60
80101863:	ff 75 08             	pushl  0x8(%ebp)
80101866:	e8 d4 fc ff ff       	call   8010153f <readsb>
8010186b:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010186e:	a1 78 3a 11 80       	mov    0x80113a78,%eax
80101873:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80101876:	8b 3d 74 3a 11 80    	mov    0x80113a74,%edi
8010187c:	8b 35 70 3a 11 80    	mov    0x80113a70,%esi
80101882:	8b 1d 6c 3a 11 80    	mov    0x80113a6c,%ebx
80101888:	8b 0d 68 3a 11 80    	mov    0x80113a68,%ecx
8010188e:	8b 15 64 3a 11 80    	mov    0x80113a64,%edx
80101894:	a1 60 3a 11 80       	mov    0x80113a60,%eax
80101899:	ff 75 d4             	pushl  -0x2c(%ebp)
8010189c:	57                   	push   %edi
8010189d:	56                   	push   %esi
8010189e:	53                   	push   %ebx
8010189f:	51                   	push   %ecx
801018a0:	52                   	push   %edx
801018a1:	50                   	push   %eax
801018a2:	68 78 96 10 80       	push   $0x80109678
801018a7:	e8 6c eb ff ff       	call   80100418 <cprintf>
801018ac:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801018af:	90                   	nop
801018b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801018b3:	5b                   	pop    %ebx
801018b4:	5e                   	pop    %esi
801018b5:	5f                   	pop    %edi
801018b6:	5d                   	pop    %ebp
801018b7:	c3                   	ret    

801018b8 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801018b8:	f3 0f 1e fb          	endbr32 
801018bc:	55                   	push   %ebp
801018bd:	89 e5                	mov    %esp,%ebp
801018bf:	83 ec 28             	sub    $0x28,%esp
801018c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801018c5:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018c9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018d0:	e9 9e 00 00 00       	jmp    80101973 <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801018d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d8:	c1 e8 03             	shr    $0x3,%eax
801018db:	89 c2                	mov    %eax,%edx
801018dd:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801018e2:	01 d0                	add    %edx,%eax
801018e4:	83 ec 08             	sub    $0x8,%esp
801018e7:	50                   	push   %eax
801018e8:	ff 75 08             	pushl  0x8(%ebp)
801018eb:	e8 e7 e8 ff ff       	call   801001d7 <bread>
801018f0:	83 c4 10             	add    $0x10,%esp
801018f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f9:	8d 50 5c             	lea    0x5c(%eax),%edx
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	83 e0 07             	and    $0x7,%eax
80101902:	c1 e0 06             	shl    $0x6,%eax
80101905:	01 d0                	add    %edx,%eax
80101907:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010190a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010190d:	0f b7 00             	movzwl (%eax),%eax
80101910:	66 85 c0             	test   %ax,%ax
80101913:	75 4c                	jne    80101961 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
80101915:	83 ec 04             	sub    $0x4,%esp
80101918:	6a 40                	push   $0x40
8010191a:	6a 00                	push   $0x0
8010191c:	ff 75 ec             	pushl  -0x14(%ebp)
8010191f:	e8 2a 3e 00 00       	call   8010574e <memset>
80101924:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101927:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010192a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010192e:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101931:	83 ec 0c             	sub    $0xc,%esp
80101934:	ff 75 f0             	pushl  -0x10(%ebp)
80101937:	e8 7e 20 00 00       	call   801039ba <log_write>
8010193c:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010193f:	83 ec 0c             	sub    $0xc,%esp
80101942:	ff 75 f0             	pushl  -0x10(%ebp)
80101945:	e8 17 e9 ff ff       	call   80100261 <brelse>
8010194a:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010194d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101950:	83 ec 08             	sub    $0x8,%esp
80101953:	50                   	push   %eax
80101954:	ff 75 08             	pushl  0x8(%ebp)
80101957:	e8 fc 00 00 00       	call   80101a58 <iget>
8010195c:	83 c4 10             	add    $0x10,%esp
8010195f:	eb 30                	jmp    80101991 <ialloc+0xd9>
    }
    brelse(bp);
80101961:	83 ec 0c             	sub    $0xc,%esp
80101964:	ff 75 f0             	pushl  -0x10(%ebp)
80101967:	e8 f5 e8 ff ff       	call   80100261 <brelse>
8010196c:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010196f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101973:	8b 15 68 3a 11 80    	mov    0x80113a68,%edx
80101979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197c:	39 c2                	cmp    %eax,%edx
8010197e:	0f 87 51 ff ff ff    	ja     801018d5 <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
80101984:	83 ec 0c             	sub    $0xc,%esp
80101987:	68 cb 96 10 80       	push   $0x801096cb
8010198c:	e8 77 ec ff ff       	call   80100608 <panic>
}
80101991:	c9                   	leave  
80101992:	c3                   	ret    

80101993 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101993:	f3 0f 1e fb          	endbr32 
80101997:	55                   	push   %ebp
80101998:	89 e5                	mov    %esp,%ebp
8010199a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010199d:	8b 45 08             	mov    0x8(%ebp),%eax
801019a0:	8b 40 04             	mov    0x4(%eax),%eax
801019a3:	c1 e8 03             	shr    $0x3,%eax
801019a6:	89 c2                	mov    %eax,%edx
801019a8:	a1 74 3a 11 80       	mov    0x80113a74,%eax
801019ad:	01 c2                	add    %eax,%edx
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	8b 00                	mov    (%eax),%eax
801019b4:	83 ec 08             	sub    $0x8,%esp
801019b7:	52                   	push   %edx
801019b8:	50                   	push   %eax
801019b9:	e8 19 e8 ff ff       	call   801001d7 <bread>
801019be:	83 c4 10             	add    $0x10,%esp
801019c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801019c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c7:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	8b 40 04             	mov    0x4(%eax),%eax
801019d0:	83 e0 07             	and    $0x7,%eax
801019d3:	c1 e0 06             	shl    $0x6,%eax
801019d6:	01 d0                	add    %edx,%eax
801019d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	0f b7 50 50          	movzwl 0x50(%eax),%edx
801019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e5:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	0f b7 50 52          	movzwl 0x52(%eax),%edx
801019ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f2:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	0f b7 50 54          	movzwl 0x54(%eax),%edx
801019fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a00:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a0e:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101a12:	8b 45 08             	mov    0x8(%ebp),%eax
80101a15:	8b 50 58             	mov    0x58(%eax),%edx
80101a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a1b:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a27:	83 c0 0c             	add    $0xc,%eax
80101a2a:	83 ec 04             	sub    $0x4,%esp
80101a2d:	6a 34                	push   $0x34
80101a2f:	52                   	push   %edx
80101a30:	50                   	push   %eax
80101a31:	e8 df 3d 00 00       	call   80105815 <memmove>
80101a36:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101a39:	83 ec 0c             	sub    $0xc,%esp
80101a3c:	ff 75 f4             	pushl  -0xc(%ebp)
80101a3f:	e8 76 1f 00 00       	call   801039ba <log_write>
80101a44:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101a47:	83 ec 0c             	sub    $0xc,%esp
80101a4a:	ff 75 f4             	pushl  -0xc(%ebp)
80101a4d:	e8 0f e8 ff ff       	call   80100261 <brelse>
80101a52:	83 c4 10             	add    $0x10,%esp
}
80101a55:	90                   	nop
80101a56:	c9                   	leave  
80101a57:	c3                   	ret    

80101a58 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a58:	f3 0f 1e fb          	endbr32 
80101a5c:	55                   	push   %ebp
80101a5d:	89 e5                	mov    %esp,%ebp
80101a5f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a62:	83 ec 0c             	sub    $0xc,%esp
80101a65:	68 80 3a 11 80       	push   $0x80113a80
80101a6a:	e8 40 3a 00 00       	call   801054af <acquire>
80101a6f:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101a72:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a79:	c7 45 f4 b4 3a 11 80 	movl   $0x80113ab4,-0xc(%ebp)
80101a80:	eb 60                	jmp    80101ae2 <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a85:	8b 40 08             	mov    0x8(%eax),%eax
80101a88:	85 c0                	test   %eax,%eax
80101a8a:	7e 39                	jle    80101ac5 <iget+0x6d>
80101a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8f:	8b 00                	mov    (%eax),%eax
80101a91:	39 45 08             	cmp    %eax,0x8(%ebp)
80101a94:	75 2f                	jne    80101ac5 <iget+0x6d>
80101a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a99:	8b 40 04             	mov    0x4(%eax),%eax
80101a9c:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101a9f:	75 24                	jne    80101ac5 <iget+0x6d>
      ip->ref++;
80101aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aa4:	8b 40 08             	mov    0x8(%eax),%eax
80101aa7:	8d 50 01             	lea    0x1(%eax),%edx
80101aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aad:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101ab0:	83 ec 0c             	sub    $0xc,%esp
80101ab3:	68 80 3a 11 80       	push   $0x80113a80
80101ab8:	e8 64 3a 00 00       	call   80105521 <release>
80101abd:	83 c4 10             	add    $0x10,%esp
      return ip;
80101ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac3:	eb 77                	jmp    80101b3c <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101ac5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101ac9:	75 10                	jne    80101adb <iget+0x83>
80101acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ace:	8b 40 08             	mov    0x8(%eax),%eax
80101ad1:	85 c0                	test   %eax,%eax
80101ad3:	75 06                	jne    80101adb <iget+0x83>
      empty = ip;
80101ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101adb:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101ae2:	81 7d f4 d4 56 11 80 	cmpl   $0x801156d4,-0xc(%ebp)
80101ae9:	72 97                	jb     80101a82 <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101aeb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aef:	75 0d                	jne    80101afe <iget+0xa6>
    panic("iget: no inodes");
80101af1:	83 ec 0c             	sub    $0xc,%esp
80101af4:	68 dd 96 10 80       	push   $0x801096dd
80101af9:	e8 0a eb ff ff       	call   80100608 <panic>

  ip = empty;
80101afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b07:	8b 55 08             	mov    0x8(%ebp),%edx
80101b0a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b12:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101b29:	83 ec 0c             	sub    $0xc,%esp
80101b2c:	68 80 3a 11 80       	push   $0x80113a80
80101b31:	e8 eb 39 00 00       	call   80105521 <release>
80101b36:	83 c4 10             	add    $0x10,%esp

  return ip;
80101b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101b3c:	c9                   	leave  
80101b3d:	c3                   	ret    

80101b3e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101b3e:	f3 0f 1e fb          	endbr32 
80101b42:	55                   	push   %ebp
80101b43:	89 e5                	mov    %esp,%ebp
80101b45:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b48:	83 ec 0c             	sub    $0xc,%esp
80101b4b:	68 80 3a 11 80       	push   $0x80113a80
80101b50:	e8 5a 39 00 00       	call   801054af <acquire>
80101b55:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	8b 40 08             	mov    0x8(%eax),%eax
80101b5e:	8d 50 01             	lea    0x1(%eax),%edx
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b67:	83 ec 0c             	sub    $0xc,%esp
80101b6a:	68 80 3a 11 80       	push   $0x80113a80
80101b6f:	e8 ad 39 00 00       	call   80105521 <release>
80101b74:	83 c4 10             	add    $0x10,%esp
  return ip;
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b7a:	c9                   	leave  
80101b7b:	c3                   	ret    

80101b7c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b7c:	f3 0f 1e fb          	endbr32 
80101b80:	55                   	push   %ebp
80101b81:	89 e5                	mov    %esp,%ebp
80101b83:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b8a:	74 0a                	je     80101b96 <ilock+0x1a>
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 40 08             	mov    0x8(%eax),%eax
80101b92:	85 c0                	test   %eax,%eax
80101b94:	7f 0d                	jg     80101ba3 <ilock+0x27>
    panic("ilock");
80101b96:	83 ec 0c             	sub    $0xc,%esp
80101b99:	68 ed 96 10 80       	push   $0x801096ed
80101b9e:	e8 65 ea ff ff       	call   80100608 <panic>

  acquiresleep(&ip->lock);
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	83 c0 0c             	add    $0xc,%eax
80101ba9:	83 ec 0c             	sub    $0xc,%esp
80101bac:	50                   	push   %eax
80101bad:	e8 84 37 00 00       	call   80105336 <acquiresleep>
80101bb2:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb8:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bbb:	85 c0                	test   %eax,%eax
80101bbd:	0f 85 cd 00 00 00    	jne    80101c90 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101bc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc6:	8b 40 04             	mov    0x4(%eax),%eax
80101bc9:	c1 e8 03             	shr    $0x3,%eax
80101bcc:	89 c2                	mov    %eax,%edx
80101bce:	a1 74 3a 11 80       	mov    0x80113a74,%eax
80101bd3:	01 c2                	add    %eax,%edx
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	8b 00                	mov    (%eax),%eax
80101bda:	83 ec 08             	sub    $0x8,%esp
80101bdd:	52                   	push   %edx
80101bde:	50                   	push   %eax
80101bdf:	e8 f3 e5 ff ff       	call   801001d7 <bread>
80101be4:	83 c4 10             	add    $0x10,%esp
80101be7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bed:	8d 50 5c             	lea    0x5c(%eax),%edx
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	8b 40 04             	mov    0x4(%eax),%eax
80101bf6:	83 e0 07             	and    $0x7,%eax
80101bf9:	c1 e0 06             	shl    $0x6,%eax
80101bfc:	01 d0                	add    %edx,%eax
80101bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c04:	0f b7 10             	movzwl (%eax),%edx
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c11:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101c15:	8b 45 08             	mov    0x8(%ebp),%eax
80101c18:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c1f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c2d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101c31:	8b 45 08             	mov    0x8(%ebp),%eax
80101c34:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c3b:	8b 50 08             	mov    0x8(%eax),%edx
80101c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c41:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c47:	8d 50 0c             	lea    0xc(%eax),%edx
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	83 c0 5c             	add    $0x5c,%eax
80101c50:	83 ec 04             	sub    $0x4,%esp
80101c53:	6a 34                	push   $0x34
80101c55:	52                   	push   %edx
80101c56:	50                   	push   %eax
80101c57:	e8 b9 3b 00 00       	call   80105815 <memmove>
80101c5c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101c5f:	83 ec 0c             	sub    $0xc,%esp
80101c62:	ff 75 f4             	pushl  -0xc(%ebp)
80101c65:	e8 f7 e5 ff ff       	call   80100261 <brelse>
80101c6a:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c70:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c77:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101c7e:	66 85 c0             	test   %ax,%ax
80101c81:	75 0d                	jne    80101c90 <ilock+0x114>
      panic("ilock: no type");
80101c83:	83 ec 0c             	sub    $0xc,%esp
80101c86:	68 f3 96 10 80       	push   $0x801096f3
80101c8b:	e8 78 e9 ff ff       	call   80100608 <panic>
  }
}
80101c90:	90                   	nop
80101c91:	c9                   	leave  
80101c92:	c3                   	ret    

80101c93 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c93:	f3 0f 1e fb          	endbr32 
80101c97:	55                   	push   %ebp
80101c98:	89 e5                	mov    %esp,%ebp
80101c9a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ca1:	74 20                	je     80101cc3 <iunlock+0x30>
80101ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca6:	83 c0 0c             	add    $0xc,%eax
80101ca9:	83 ec 0c             	sub    $0xc,%esp
80101cac:	50                   	push   %eax
80101cad:	e8 3e 37 00 00       	call   801053f0 <holdingsleep>
80101cb2:	83 c4 10             	add    $0x10,%esp
80101cb5:	85 c0                	test   %eax,%eax
80101cb7:	74 0a                	je     80101cc3 <iunlock+0x30>
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 40 08             	mov    0x8(%eax),%eax
80101cbf:	85 c0                	test   %eax,%eax
80101cc1:	7f 0d                	jg     80101cd0 <iunlock+0x3d>
    panic("iunlock");
80101cc3:	83 ec 0c             	sub    $0xc,%esp
80101cc6:	68 02 97 10 80       	push   $0x80109702
80101ccb:	e8 38 e9 ff ff       	call   80100608 <panic>

  releasesleep(&ip->lock);
80101cd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd3:	83 c0 0c             	add    $0xc,%eax
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	50                   	push   %eax
80101cda:	e8 bf 36 00 00       	call   8010539e <releasesleep>
80101cdf:	83 c4 10             	add    $0x10,%esp
}
80101ce2:	90                   	nop
80101ce3:	c9                   	leave  
80101ce4:	c3                   	ret    

80101ce5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101ce5:	f3 0f 1e fb          	endbr32 
80101ce9:	55                   	push   %ebp
80101cea:	89 e5                	mov    %esp,%ebp
80101cec:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	83 c0 0c             	add    $0xc,%eax
80101cf5:	83 ec 0c             	sub    $0xc,%esp
80101cf8:	50                   	push   %eax
80101cf9:	e8 38 36 00 00       	call   80105336 <acquiresleep>
80101cfe:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d07:	85 c0                	test   %eax,%eax
80101d09:	74 6a                	je     80101d75 <iput+0x90>
80101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0e:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101d12:	66 85 c0             	test   %ax,%ax
80101d15:	75 5e                	jne    80101d75 <iput+0x90>
    acquire(&icache.lock);
80101d17:	83 ec 0c             	sub    $0xc,%esp
80101d1a:	68 80 3a 11 80       	push   $0x80113a80
80101d1f:	e8 8b 37 00 00       	call   801054af <acquire>
80101d24:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101d27:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2a:	8b 40 08             	mov    0x8(%eax),%eax
80101d2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101d30:	83 ec 0c             	sub    $0xc,%esp
80101d33:	68 80 3a 11 80       	push   $0x80113a80
80101d38:	e8 e4 37 00 00       	call   80105521 <release>
80101d3d:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101d40:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101d44:	75 2f                	jne    80101d75 <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 08             	pushl  0x8(%ebp)
80101d4c:	e8 b5 01 00 00       	call   80101f06 <itrunc>
80101d51:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101d5d:	83 ec 0c             	sub    $0xc,%esp
80101d60:	ff 75 08             	pushl  0x8(%ebp)
80101d63:	e8 2b fc ff ff       	call   80101993 <iupdate>
80101d68:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101d75:	8b 45 08             	mov    0x8(%ebp),%eax
80101d78:	83 c0 0c             	add    $0xc,%eax
80101d7b:	83 ec 0c             	sub    $0xc,%esp
80101d7e:	50                   	push   %eax
80101d7f:	e8 1a 36 00 00       	call   8010539e <releasesleep>
80101d84:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101d87:	83 ec 0c             	sub    $0xc,%esp
80101d8a:	68 80 3a 11 80       	push   $0x80113a80
80101d8f:	e8 1b 37 00 00       	call   801054af <acquire>
80101d94:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	8b 40 08             	mov    0x8(%eax),%eax
80101d9d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101da0:	8b 45 08             	mov    0x8(%ebp),%eax
80101da3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101da6:	83 ec 0c             	sub    $0xc,%esp
80101da9:	68 80 3a 11 80       	push   $0x80113a80
80101dae:	e8 6e 37 00 00       	call   80105521 <release>
80101db3:	83 c4 10             	add    $0x10,%esp
}
80101db6:	90                   	nop
80101db7:	c9                   	leave  
80101db8:	c3                   	ret    

80101db9 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101db9:	f3 0f 1e fb          	endbr32 
80101dbd:	55                   	push   %ebp
80101dbe:	89 e5                	mov    %esp,%ebp
80101dc0:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	ff 75 08             	pushl  0x8(%ebp)
80101dc9:	e8 c5 fe ff ff       	call   80101c93 <iunlock>
80101dce:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101dd1:	83 ec 0c             	sub    $0xc,%esp
80101dd4:	ff 75 08             	pushl  0x8(%ebp)
80101dd7:	e8 09 ff ff ff       	call   80101ce5 <iput>
80101ddc:	83 c4 10             	add    $0x10,%esp
}
80101ddf:	90                   	nop
80101de0:	c9                   	leave  
80101de1:	c3                   	ret    

80101de2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101de2:	f3 0f 1e fb          	endbr32 
80101de6:	55                   	push   %ebp
80101de7:	89 e5                	mov    %esp,%ebp
80101de9:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101dec:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101df0:	77 42                	ja     80101e34 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101df2:	8b 45 08             	mov    0x8(%ebp),%eax
80101df5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101df8:	83 c2 14             	add    $0x14,%edx
80101dfb:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dff:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e06:	75 24                	jne    80101e2c <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101e08:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0b:	8b 00                	mov    (%eax),%eax
80101e0d:	83 ec 0c             	sub    $0xc,%esp
80101e10:	50                   	push   %eax
80101e11:	e8 c7 f7 ff ff       	call   801015dd <balloc>
80101e16:	83 c4 10             	add    $0x10,%esp
80101e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e22:	8d 4a 14             	lea    0x14(%edx),%ecx
80101e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e2f:	e9 d0 00 00 00       	jmp    80101f04 <bmap+0x122>
  }
  bn -= NDIRECT;
80101e34:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101e38:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101e3c:	0f 87 b5 00 00 00    	ja     80101ef7 <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101e42:	8b 45 08             	mov    0x8(%ebp),%eax
80101e45:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e52:	75 20                	jne    80101e74 <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101e54:	8b 45 08             	mov    0x8(%ebp),%eax
80101e57:	8b 00                	mov    (%eax),%eax
80101e59:	83 ec 0c             	sub    $0xc,%esp
80101e5c:	50                   	push   %eax
80101e5d:	e8 7b f7 ff ff       	call   801015dd <balloc>
80101e62:	83 c4 10             	add    $0x10,%esp
80101e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e68:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101e74:	8b 45 08             	mov    0x8(%ebp),%eax
80101e77:	8b 00                	mov    (%eax),%eax
80101e79:	83 ec 08             	sub    $0x8,%esp
80101e7c:	ff 75 f4             	pushl  -0xc(%ebp)
80101e7f:	50                   	push   %eax
80101e80:	e8 52 e3 ff ff       	call   801001d7 <bread>
80101e85:	83 c4 10             	add    $0x10,%esp
80101e88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8e:	83 c0 5c             	add    $0x5c,%eax
80101e91:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101e94:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e97:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea1:	01 d0                	add    %edx,%eax
80101ea3:	8b 00                	mov    (%eax),%eax
80101ea5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ea8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101eac:	75 36                	jne    80101ee4 <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	8b 00                	mov    (%eax),%eax
80101eb3:	83 ec 0c             	sub    $0xc,%esp
80101eb6:	50                   	push   %eax
80101eb7:	e8 21 f7 ff ff       	call   801015dd <balloc>
80101ebc:	83 c4 10             	add    $0x10,%esp
80101ebf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecf:	01 c2                	add    %eax,%edx
80101ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ed4:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101ed6:	83 ec 0c             	sub    $0xc,%esp
80101ed9:	ff 75 f0             	pushl  -0x10(%ebp)
80101edc:	e8 d9 1a 00 00       	call   801039ba <log_write>
80101ee1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ee4:	83 ec 0c             	sub    $0xc,%esp
80101ee7:	ff 75 f0             	pushl  -0x10(%ebp)
80101eea:	e8 72 e3 ff ff       	call   80100261 <brelse>
80101eef:	83 c4 10             	add    $0x10,%esp
    return addr;
80101ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ef5:	eb 0d                	jmp    80101f04 <bmap+0x122>
  }

  panic("bmap: out of range");
80101ef7:	83 ec 0c             	sub    $0xc,%esp
80101efa:	68 0a 97 10 80       	push   $0x8010970a
80101eff:	e8 04 e7 ff ff       	call   80100608 <panic>
}
80101f04:	c9                   	leave  
80101f05:	c3                   	ret    

80101f06 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101f06:	f3 0f 1e fb          	endbr32 
80101f0a:	55                   	push   %ebp
80101f0b:	89 e5                	mov    %esp,%ebp
80101f0d:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101f10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f17:	eb 45                	jmp    80101f5e <itrunc+0x58>
    if(ip->addrs[i]){
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f1f:	83 c2 14             	add    $0x14,%edx
80101f22:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f26:	85 c0                	test   %eax,%eax
80101f28:	74 30                	je     80101f5a <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f30:	83 c2 14             	add    $0x14,%edx
80101f33:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101f37:	8b 55 08             	mov    0x8(%ebp),%edx
80101f3a:	8b 12                	mov    (%edx),%edx
80101f3c:	83 ec 08             	sub    $0x8,%esp
80101f3f:	50                   	push   %eax
80101f40:	52                   	push   %edx
80101f41:	e8 e7 f7 ff ff       	call   8010172d <bfree>
80101f46:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101f4f:	83 c2 14             	add    $0x14,%edx
80101f52:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101f59:	00 
  for(i = 0; i < NDIRECT; i++){
80101f5a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101f5e:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101f62:	7e b5                	jle    80101f19 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101f64:	8b 45 08             	mov    0x8(%ebp),%eax
80101f67:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f6d:	85 c0                	test   %eax,%eax
80101f6f:	0f 84 aa 00 00 00    	je     8010201f <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101f75:	8b 45 08             	mov    0x8(%ebp),%eax
80101f78:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f81:	8b 00                	mov    (%eax),%eax
80101f83:	83 ec 08             	sub    $0x8,%esp
80101f86:	52                   	push   %edx
80101f87:	50                   	push   %eax
80101f88:	e8 4a e2 ff ff       	call   801001d7 <bread>
80101f8d:	83 c4 10             	add    $0x10,%esp
80101f90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101f93:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f96:	83 c0 5c             	add    $0x5c,%eax
80101f99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101f9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101fa3:	eb 3c                	jmp    80101fe1 <itrunc+0xdb>
      if(a[j])
80101fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fa8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101faf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fb2:	01 d0                	add    %edx,%eax
80101fb4:	8b 00                	mov    (%eax),%eax
80101fb6:	85 c0                	test   %eax,%eax
80101fb8:	74 23                	je     80101fdd <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101fc4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101fc7:	01 d0                	add    %edx,%eax
80101fc9:	8b 00                	mov    (%eax),%eax
80101fcb:	8b 55 08             	mov    0x8(%ebp),%edx
80101fce:	8b 12                	mov    (%edx),%edx
80101fd0:	83 ec 08             	sub    $0x8,%esp
80101fd3:	50                   	push   %eax
80101fd4:	52                   	push   %edx
80101fd5:	e8 53 f7 ff ff       	call   8010172d <bfree>
80101fda:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101fdd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101fe1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe4:	83 f8 7f             	cmp    $0x7f,%eax
80101fe7:	76 bc                	jbe    80101fa5 <itrunc+0x9f>
    }
    brelse(bp);
80101fe9:	83 ec 0c             	sub    $0xc,%esp
80101fec:	ff 75 ec             	pushl  -0x14(%ebp)
80101fef:	e8 6d e2 ff ff       	call   80100261 <brelse>
80101ff4:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffa:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80102000:	8b 55 08             	mov    0x8(%ebp),%edx
80102003:	8b 12                	mov    (%edx),%edx
80102005:	83 ec 08             	sub    $0x8,%esp
80102008:	50                   	push   %eax
80102009:	52                   	push   %edx
8010200a:	e8 1e f7 ff ff       	call   8010172d <bfree>
8010200f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80102012:	8b 45 08             	mov    0x8(%ebp),%eax
80102015:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
8010201c:	00 00 00 
  }

  ip->size = 0;
8010201f:	8b 45 08             	mov    0x8(%ebp),%eax
80102022:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80102029:	83 ec 0c             	sub    $0xc,%esp
8010202c:	ff 75 08             	pushl  0x8(%ebp)
8010202f:	e8 5f f9 ff ff       	call   80101993 <iupdate>
80102034:	83 c4 10             	add    $0x10,%esp
}
80102037:	90                   	nop
80102038:	c9                   	leave  
80102039:	c3                   	ret    

8010203a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
8010203a:	f3 0f 1e fb          	endbr32 
8010203e:	55                   	push   %ebp
8010203f:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80102041:	8b 45 08             	mov    0x8(%ebp),%eax
80102044:	8b 00                	mov    (%eax),%eax
80102046:	89 c2                	mov    %eax,%edx
80102048:	8b 45 0c             	mov    0xc(%ebp),%eax
8010204b:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	8b 50 04             	mov    0x4(%eax),%edx
80102054:	8b 45 0c             	mov    0xc(%ebp),%eax
80102057:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80102061:	8b 45 0c             	mov    0xc(%ebp),%eax
80102064:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80102067:	8b 45 08             	mov    0x8(%ebp),%eax
8010206a:	0f b7 50 56          	movzwl 0x56(%eax),%edx
8010206e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102071:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	8b 50 58             	mov    0x58(%eax),%edx
8010207b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102081:	90                   	nop
80102082:	5d                   	pop    %ebp
80102083:	c3                   	ret    

80102084 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80102084:	f3 0f 1e fb          	endbr32 
80102088:	55                   	push   %ebp
80102089:	89 e5                	mov    %esp,%ebp
8010208b:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010208e:	8b 45 08             	mov    0x8(%ebp),%eax
80102091:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102095:	66 83 f8 03          	cmp    $0x3,%ax
80102099:	75 5c                	jne    801020f7 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
8010209b:	8b 45 08             	mov    0x8(%ebp),%eax
8010209e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020a2:	66 85 c0             	test   %ax,%ax
801020a5:	78 20                	js     801020c7 <readi+0x43>
801020a7:	8b 45 08             	mov    0x8(%ebp),%eax
801020aa:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020ae:	66 83 f8 09          	cmp    $0x9,%ax
801020b2:	7f 13                	jg     801020c7 <readi+0x43>
801020b4:	8b 45 08             	mov    0x8(%ebp),%eax
801020b7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020bb:	98                   	cwtl   
801020bc:	8b 04 c5 00 3a 11 80 	mov    -0x7feec600(,%eax,8),%eax
801020c3:	85 c0                	test   %eax,%eax
801020c5:	75 0a                	jne    801020d1 <readi+0x4d>
      return -1;
801020c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020cc:	e9 0a 01 00 00       	jmp    801021db <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
801020d1:	8b 45 08             	mov    0x8(%ebp),%eax
801020d4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801020d8:	98                   	cwtl   
801020d9:	8b 04 c5 00 3a 11 80 	mov    -0x7feec600(,%eax,8),%eax
801020e0:	8b 55 14             	mov    0x14(%ebp),%edx
801020e3:	83 ec 04             	sub    $0x4,%esp
801020e6:	52                   	push   %edx
801020e7:	ff 75 0c             	pushl  0xc(%ebp)
801020ea:	ff 75 08             	pushl  0x8(%ebp)
801020ed:	ff d0                	call   *%eax
801020ef:	83 c4 10             	add    $0x10,%esp
801020f2:	e9 e4 00 00 00       	jmp    801021db <readi+0x157>
  }

  if(off > ip->size || off + n < off)
801020f7:	8b 45 08             	mov    0x8(%ebp),%eax
801020fa:	8b 40 58             	mov    0x58(%eax),%eax
801020fd:	39 45 10             	cmp    %eax,0x10(%ebp)
80102100:	77 0d                	ja     8010210f <readi+0x8b>
80102102:	8b 55 10             	mov    0x10(%ebp),%edx
80102105:	8b 45 14             	mov    0x14(%ebp),%eax
80102108:	01 d0                	add    %edx,%eax
8010210a:	39 45 10             	cmp    %eax,0x10(%ebp)
8010210d:	76 0a                	jbe    80102119 <readi+0x95>
    return -1;
8010210f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102114:	e9 c2 00 00 00       	jmp    801021db <readi+0x157>
  if(off + n > ip->size)
80102119:	8b 55 10             	mov    0x10(%ebp),%edx
8010211c:	8b 45 14             	mov    0x14(%ebp),%eax
8010211f:	01 c2                	add    %eax,%edx
80102121:	8b 45 08             	mov    0x8(%ebp),%eax
80102124:	8b 40 58             	mov    0x58(%eax),%eax
80102127:	39 c2                	cmp    %eax,%edx
80102129:	76 0c                	jbe    80102137 <readi+0xb3>
    n = ip->size - off;
8010212b:	8b 45 08             	mov    0x8(%ebp),%eax
8010212e:	8b 40 58             	mov    0x58(%eax),%eax
80102131:	2b 45 10             	sub    0x10(%ebp),%eax
80102134:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102137:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010213e:	e9 89 00 00 00       	jmp    801021cc <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102143:	8b 45 10             	mov    0x10(%ebp),%eax
80102146:	c1 e8 09             	shr    $0x9,%eax
80102149:	83 ec 08             	sub    $0x8,%esp
8010214c:	50                   	push   %eax
8010214d:	ff 75 08             	pushl  0x8(%ebp)
80102150:	e8 8d fc ff ff       	call   80101de2 <bmap>
80102155:	83 c4 10             	add    $0x10,%esp
80102158:	8b 55 08             	mov    0x8(%ebp),%edx
8010215b:	8b 12                	mov    (%edx),%edx
8010215d:	83 ec 08             	sub    $0x8,%esp
80102160:	50                   	push   %eax
80102161:	52                   	push   %edx
80102162:	e8 70 e0 ff ff       	call   801001d7 <bread>
80102167:	83 c4 10             	add    $0x10,%esp
8010216a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010216d:	8b 45 10             	mov    0x10(%ebp),%eax
80102170:	25 ff 01 00 00       	and    $0x1ff,%eax
80102175:	ba 00 02 00 00       	mov    $0x200,%edx
8010217a:	29 c2                	sub    %eax,%edx
8010217c:	8b 45 14             	mov    0x14(%ebp),%eax
8010217f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102182:	39 c2                	cmp    %eax,%edx
80102184:	0f 46 c2             	cmovbe %edx,%eax
80102187:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010218a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010218d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102190:	8b 45 10             	mov    0x10(%ebp),%eax
80102193:	25 ff 01 00 00       	and    $0x1ff,%eax
80102198:	01 d0                	add    %edx,%eax
8010219a:	83 ec 04             	sub    $0x4,%esp
8010219d:	ff 75 ec             	pushl  -0x14(%ebp)
801021a0:	50                   	push   %eax
801021a1:	ff 75 0c             	pushl  0xc(%ebp)
801021a4:	e8 6c 36 00 00       	call   80105815 <memmove>
801021a9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801021ac:	83 ec 0c             	sub    $0xc,%esp
801021af:	ff 75 f0             	pushl  -0x10(%ebp)
801021b2:	e8 aa e0 ff ff       	call   80100261 <brelse>
801021b7:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801021ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021bd:	01 45 f4             	add    %eax,-0xc(%ebp)
801021c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c3:	01 45 10             	add    %eax,0x10(%ebp)
801021c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021c9:	01 45 0c             	add    %eax,0xc(%ebp)
801021cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801021d2:	0f 82 6b ff ff ff    	jb     80102143 <readi+0xbf>
  }
  return n;
801021d8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021db:	c9                   	leave  
801021dc:	c3                   	ret    

801021dd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801021dd:	f3 0f 1e fb          	endbr32 
801021e1:	55                   	push   %ebp
801021e2:	89 e5                	mov    %esp,%ebp
801021e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801021e7:	8b 45 08             	mov    0x8(%ebp),%eax
801021ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021ee:	66 83 f8 03          	cmp    $0x3,%ax
801021f2:	75 5c                	jne    80102250 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801021f4:	8b 45 08             	mov    0x8(%ebp),%eax
801021f7:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801021fb:	66 85 c0             	test   %ax,%ax
801021fe:	78 20                	js     80102220 <writei+0x43>
80102200:	8b 45 08             	mov    0x8(%ebp),%eax
80102203:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102207:	66 83 f8 09          	cmp    $0x9,%ax
8010220b:	7f 13                	jg     80102220 <writei+0x43>
8010220d:	8b 45 08             	mov    0x8(%ebp),%eax
80102210:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102214:	98                   	cwtl   
80102215:	8b 04 c5 04 3a 11 80 	mov    -0x7feec5fc(,%eax,8),%eax
8010221c:	85 c0                	test   %eax,%eax
8010221e:	75 0a                	jne    8010222a <writei+0x4d>
      return -1;
80102220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102225:	e9 3b 01 00 00       	jmp    80102365 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010222a:	8b 45 08             	mov    0x8(%ebp),%eax
8010222d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102231:	98                   	cwtl   
80102232:	8b 04 c5 04 3a 11 80 	mov    -0x7feec5fc(,%eax,8),%eax
80102239:	8b 55 14             	mov    0x14(%ebp),%edx
8010223c:	83 ec 04             	sub    $0x4,%esp
8010223f:	52                   	push   %edx
80102240:	ff 75 0c             	pushl  0xc(%ebp)
80102243:	ff 75 08             	pushl  0x8(%ebp)
80102246:	ff d0                	call   *%eax
80102248:	83 c4 10             	add    $0x10,%esp
8010224b:	e9 15 01 00 00       	jmp    80102365 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	8b 40 58             	mov    0x58(%eax),%eax
80102256:	39 45 10             	cmp    %eax,0x10(%ebp)
80102259:	77 0d                	ja     80102268 <writei+0x8b>
8010225b:	8b 55 10             	mov    0x10(%ebp),%edx
8010225e:	8b 45 14             	mov    0x14(%ebp),%eax
80102261:	01 d0                	add    %edx,%eax
80102263:	39 45 10             	cmp    %eax,0x10(%ebp)
80102266:	76 0a                	jbe    80102272 <writei+0x95>
    return -1;
80102268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010226d:	e9 f3 00 00 00       	jmp    80102365 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102272:	8b 55 10             	mov    0x10(%ebp),%edx
80102275:	8b 45 14             	mov    0x14(%ebp),%eax
80102278:	01 d0                	add    %edx,%eax
8010227a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010227f:	76 0a                	jbe    8010228b <writei+0xae>
    return -1;
80102281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102286:	e9 da 00 00 00       	jmp    80102365 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010228b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102292:	e9 97 00 00 00       	jmp    8010232e <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102297:	8b 45 10             	mov    0x10(%ebp),%eax
8010229a:	c1 e8 09             	shr    $0x9,%eax
8010229d:	83 ec 08             	sub    $0x8,%esp
801022a0:	50                   	push   %eax
801022a1:	ff 75 08             	pushl  0x8(%ebp)
801022a4:	e8 39 fb ff ff       	call   80101de2 <bmap>
801022a9:	83 c4 10             	add    $0x10,%esp
801022ac:	8b 55 08             	mov    0x8(%ebp),%edx
801022af:	8b 12                	mov    (%edx),%edx
801022b1:	83 ec 08             	sub    $0x8,%esp
801022b4:	50                   	push   %eax
801022b5:	52                   	push   %edx
801022b6:	e8 1c df ff ff       	call   801001d7 <bread>
801022bb:	83 c4 10             	add    $0x10,%esp
801022be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801022c1:	8b 45 10             	mov    0x10(%ebp),%eax
801022c4:	25 ff 01 00 00       	and    $0x1ff,%eax
801022c9:	ba 00 02 00 00       	mov    $0x200,%edx
801022ce:	29 c2                	sub    %eax,%edx
801022d0:	8b 45 14             	mov    0x14(%ebp),%eax
801022d3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801022d6:	39 c2                	cmp    %eax,%edx
801022d8:	0f 46 c2             	cmovbe %edx,%eax
801022db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801022de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e1:	8d 50 5c             	lea    0x5c(%eax),%edx
801022e4:	8b 45 10             	mov    0x10(%ebp),%eax
801022e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801022ec:	01 d0                	add    %edx,%eax
801022ee:	83 ec 04             	sub    $0x4,%esp
801022f1:	ff 75 ec             	pushl  -0x14(%ebp)
801022f4:	ff 75 0c             	pushl  0xc(%ebp)
801022f7:	50                   	push   %eax
801022f8:	e8 18 35 00 00       	call   80105815 <memmove>
801022fd:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102300:	83 ec 0c             	sub    $0xc,%esp
80102303:	ff 75 f0             	pushl  -0x10(%ebp)
80102306:	e8 af 16 00 00       	call   801039ba <log_write>
8010230b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010230e:	83 ec 0c             	sub    $0xc,%esp
80102311:	ff 75 f0             	pushl  -0x10(%ebp)
80102314:	e8 48 df ff ff       	call   80100261 <brelse>
80102319:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010231c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010231f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102322:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102325:	01 45 10             	add    %eax,0x10(%ebp)
80102328:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010232b:	01 45 0c             	add    %eax,0xc(%ebp)
8010232e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102331:	3b 45 14             	cmp    0x14(%ebp),%eax
80102334:	0f 82 5d ff ff ff    	jb     80102297 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010233a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010233e:	74 22                	je     80102362 <writei+0x185>
80102340:	8b 45 08             	mov    0x8(%ebp),%eax
80102343:	8b 40 58             	mov    0x58(%eax),%eax
80102346:	39 45 10             	cmp    %eax,0x10(%ebp)
80102349:	76 17                	jbe    80102362 <writei+0x185>
    ip->size = off;
8010234b:	8b 45 08             	mov    0x8(%ebp),%eax
8010234e:	8b 55 10             	mov    0x10(%ebp),%edx
80102351:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102354:	83 ec 0c             	sub    $0xc,%esp
80102357:	ff 75 08             	pushl  0x8(%ebp)
8010235a:	e8 34 f6 ff ff       	call   80101993 <iupdate>
8010235f:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102362:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102365:	c9                   	leave  
80102366:	c3                   	ret    

80102367 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102367:	f3 0f 1e fb          	endbr32 
8010236b:	55                   	push   %ebp
8010236c:	89 e5                	mov    %esp,%ebp
8010236e:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102371:	83 ec 04             	sub    $0x4,%esp
80102374:	6a 0e                	push   $0xe
80102376:	ff 75 0c             	pushl  0xc(%ebp)
80102379:	ff 75 08             	pushl  0x8(%ebp)
8010237c:	e8 32 35 00 00       	call   801058b3 <strncmp>
80102381:	83 c4 10             	add    $0x10,%esp
}
80102384:	c9                   	leave  
80102385:	c3                   	ret    

80102386 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102386:	f3 0f 1e fb          	endbr32 
8010238a:	55                   	push   %ebp
8010238b:	89 e5                	mov    %esp,%ebp
8010238d:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102397:	66 83 f8 01          	cmp    $0x1,%ax
8010239b:	74 0d                	je     801023aa <dirlookup+0x24>
    panic("dirlookup not DIR");
8010239d:	83 ec 0c             	sub    $0xc,%esp
801023a0:	68 1d 97 10 80       	push   $0x8010971d
801023a5:	e8 5e e2 ff ff       	call   80100608 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801023aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b1:	eb 7b                	jmp    8010242e <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023b3:	6a 10                	push   $0x10
801023b5:	ff 75 f4             	pushl  -0xc(%ebp)
801023b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023bb:	50                   	push   %eax
801023bc:	ff 75 08             	pushl  0x8(%ebp)
801023bf:	e8 c0 fc ff ff       	call   80102084 <readi>
801023c4:	83 c4 10             	add    $0x10,%esp
801023c7:	83 f8 10             	cmp    $0x10,%eax
801023ca:	74 0d                	je     801023d9 <dirlookup+0x53>
      panic("dirlookup read");
801023cc:	83 ec 0c             	sub    $0xc,%esp
801023cf:	68 2f 97 10 80       	push   $0x8010972f
801023d4:	e8 2f e2 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801023d9:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023dd:	66 85 c0             	test   %ax,%ax
801023e0:	74 47                	je     80102429 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801023e2:	83 ec 08             	sub    $0x8,%esp
801023e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023e8:	83 c0 02             	add    $0x2,%eax
801023eb:	50                   	push   %eax
801023ec:	ff 75 0c             	pushl  0xc(%ebp)
801023ef:	e8 73 ff ff ff       	call   80102367 <namecmp>
801023f4:	83 c4 10             	add    $0x10,%esp
801023f7:	85 c0                	test   %eax,%eax
801023f9:	75 2f                	jne    8010242a <dirlookup+0xa4>
      // entry matches path element
      if(poff)
801023fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023ff:	74 08                	je     80102409 <dirlookup+0x83>
        *poff = off;
80102401:	8b 45 10             	mov    0x10(%ebp),%eax
80102404:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102407:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102409:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010240d:	0f b7 c0             	movzwl %ax,%eax
80102410:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102413:	8b 45 08             	mov    0x8(%ebp),%eax
80102416:	8b 00                	mov    (%eax),%eax
80102418:	83 ec 08             	sub    $0x8,%esp
8010241b:	ff 75 f0             	pushl  -0x10(%ebp)
8010241e:	50                   	push   %eax
8010241f:	e8 34 f6 ff ff       	call   80101a58 <iget>
80102424:	83 c4 10             	add    $0x10,%esp
80102427:	eb 19                	jmp    80102442 <dirlookup+0xbc>
      continue;
80102429:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010242a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010242e:	8b 45 08             	mov    0x8(%ebp),%eax
80102431:	8b 40 58             	mov    0x58(%eax),%eax
80102434:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102437:	0f 82 76 ff ff ff    	jb     801023b3 <dirlookup+0x2d>
    }
  }

  return 0;
8010243d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102442:	c9                   	leave  
80102443:	c3                   	ret    

80102444 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102444:	f3 0f 1e fb          	endbr32 
80102448:	55                   	push   %ebp
80102449:	89 e5                	mov    %esp,%ebp
8010244b:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010244e:	83 ec 04             	sub    $0x4,%esp
80102451:	6a 00                	push   $0x0
80102453:	ff 75 0c             	pushl  0xc(%ebp)
80102456:	ff 75 08             	pushl  0x8(%ebp)
80102459:	e8 28 ff ff ff       	call   80102386 <dirlookup>
8010245e:	83 c4 10             	add    $0x10,%esp
80102461:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102464:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102468:	74 18                	je     80102482 <dirlink+0x3e>
    iput(ip);
8010246a:	83 ec 0c             	sub    $0xc,%esp
8010246d:	ff 75 f0             	pushl  -0x10(%ebp)
80102470:	e8 70 f8 ff ff       	call   80101ce5 <iput>
80102475:	83 c4 10             	add    $0x10,%esp
    return -1;
80102478:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010247d:	e9 9c 00 00 00       	jmp    8010251e <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102482:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102489:	eb 39                	jmp    801024c4 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010248b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010248e:	6a 10                	push   $0x10
80102490:	50                   	push   %eax
80102491:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102494:	50                   	push   %eax
80102495:	ff 75 08             	pushl  0x8(%ebp)
80102498:	e8 e7 fb ff ff       	call   80102084 <readi>
8010249d:	83 c4 10             	add    $0x10,%esp
801024a0:	83 f8 10             	cmp    $0x10,%eax
801024a3:	74 0d                	je     801024b2 <dirlink+0x6e>
      panic("dirlink read");
801024a5:	83 ec 0c             	sub    $0xc,%esp
801024a8:	68 3e 97 10 80       	push   $0x8010973e
801024ad:	e8 56 e1 ff ff       	call   80100608 <panic>
    if(de.inum == 0)
801024b2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801024b6:	66 85 c0             	test   %ax,%ax
801024b9:	74 18                	je     801024d3 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801024bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024be:	83 c0 10             	add    $0x10,%eax
801024c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024c4:	8b 45 08             	mov    0x8(%ebp),%eax
801024c7:	8b 50 58             	mov    0x58(%eax),%edx
801024ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024cd:	39 c2                	cmp    %eax,%edx
801024cf:	77 ba                	ja     8010248b <dirlink+0x47>
801024d1:	eb 01                	jmp    801024d4 <dirlink+0x90>
      break;
801024d3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801024d4:	83 ec 04             	sub    $0x4,%esp
801024d7:	6a 0e                	push   $0xe
801024d9:	ff 75 0c             	pushl  0xc(%ebp)
801024dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024df:	83 c0 02             	add    $0x2,%eax
801024e2:	50                   	push   %eax
801024e3:	e8 25 34 00 00       	call   8010590d <strncpy>
801024e8:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801024eb:	8b 45 10             	mov    0x10(%ebp),%eax
801024ee:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f5:	6a 10                	push   $0x10
801024f7:	50                   	push   %eax
801024f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024fb:	50                   	push   %eax
801024fc:	ff 75 08             	pushl  0x8(%ebp)
801024ff:	e8 d9 fc ff ff       	call   801021dd <writei>
80102504:	83 c4 10             	add    $0x10,%esp
80102507:	83 f8 10             	cmp    $0x10,%eax
8010250a:	74 0d                	je     80102519 <dirlink+0xd5>
    panic("dirlink");
8010250c:	83 ec 0c             	sub    $0xc,%esp
8010250f:	68 4b 97 10 80       	push   $0x8010974b
80102514:	e8 ef e0 ff ff       	call   80100608 <panic>

  return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010251e:	c9                   	leave  
8010251f:	c3                   	ret    

80102520 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102520:	f3 0f 1e fb          	endbr32 
80102524:	55                   	push   %ebp
80102525:	89 e5                	mov    %esp,%ebp
80102527:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010252a:	eb 04                	jmp    80102530 <skipelem+0x10>
    path++;
8010252c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102530:	8b 45 08             	mov    0x8(%ebp),%eax
80102533:	0f b6 00             	movzbl (%eax),%eax
80102536:	3c 2f                	cmp    $0x2f,%al
80102538:	74 f2                	je     8010252c <skipelem+0xc>
  if(*path == 0)
8010253a:	8b 45 08             	mov    0x8(%ebp),%eax
8010253d:	0f b6 00             	movzbl (%eax),%eax
80102540:	84 c0                	test   %al,%al
80102542:	75 07                	jne    8010254b <skipelem+0x2b>
    return 0;
80102544:	b8 00 00 00 00       	mov    $0x0,%eax
80102549:	eb 77                	jmp    801025c2 <skipelem+0xa2>
  s = path;
8010254b:	8b 45 08             	mov    0x8(%ebp),%eax
8010254e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102551:	eb 04                	jmp    80102557 <skipelem+0x37>
    path++;
80102553:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102557:	8b 45 08             	mov    0x8(%ebp),%eax
8010255a:	0f b6 00             	movzbl (%eax),%eax
8010255d:	3c 2f                	cmp    $0x2f,%al
8010255f:	74 0a                	je     8010256b <skipelem+0x4b>
80102561:	8b 45 08             	mov    0x8(%ebp),%eax
80102564:	0f b6 00             	movzbl (%eax),%eax
80102567:	84 c0                	test   %al,%al
80102569:	75 e8                	jne    80102553 <skipelem+0x33>
  len = path - s;
8010256b:	8b 45 08             	mov    0x8(%ebp),%eax
8010256e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102571:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102574:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102578:	7e 15                	jle    8010258f <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010257a:	83 ec 04             	sub    $0x4,%esp
8010257d:	6a 0e                	push   $0xe
8010257f:	ff 75 f4             	pushl  -0xc(%ebp)
80102582:	ff 75 0c             	pushl  0xc(%ebp)
80102585:	e8 8b 32 00 00       	call   80105815 <memmove>
8010258a:	83 c4 10             	add    $0x10,%esp
8010258d:	eb 26                	jmp    801025b5 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010258f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102592:	83 ec 04             	sub    $0x4,%esp
80102595:	50                   	push   %eax
80102596:	ff 75 f4             	pushl  -0xc(%ebp)
80102599:	ff 75 0c             	pushl  0xc(%ebp)
8010259c:	e8 74 32 00 00       	call   80105815 <memmove>
801025a1:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801025a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801025a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801025aa:	01 d0                	add    %edx,%eax
801025ac:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801025af:	eb 04                	jmp    801025b5 <skipelem+0x95>
    path++;
801025b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801025b5:	8b 45 08             	mov    0x8(%ebp),%eax
801025b8:	0f b6 00             	movzbl (%eax),%eax
801025bb:	3c 2f                	cmp    $0x2f,%al
801025bd:	74 f2                	je     801025b1 <skipelem+0x91>
  return path;
801025bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025c2:	c9                   	leave  
801025c3:	c3                   	ret    

801025c4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025c4:	f3 0f 1e fb          	endbr32 
801025c8:	55                   	push   %ebp
801025c9:	89 e5                	mov    %esp,%ebp
801025cb:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025ce:	8b 45 08             	mov    0x8(%ebp),%eax
801025d1:	0f b6 00             	movzbl (%eax),%eax
801025d4:	3c 2f                	cmp    $0x2f,%al
801025d6:	75 17                	jne    801025ef <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801025d8:	83 ec 08             	sub    $0x8,%esp
801025db:	6a 01                	push   $0x1
801025dd:	6a 01                	push   $0x1
801025df:	e8 74 f4 ff ff       	call   80101a58 <iget>
801025e4:	83 c4 10             	add    $0x10,%esp
801025e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801025ea:	e9 ba 00 00 00       	jmp    801026a9 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
801025ef:	e8 3c 1f 00 00       	call   80104530 <myproc>
801025f4:	8b 40 68             	mov    0x68(%eax),%eax
801025f7:	83 ec 0c             	sub    $0xc,%esp
801025fa:	50                   	push   %eax
801025fb:	e8 3e f5 ff ff       	call   80101b3e <idup>
80102600:	83 c4 10             	add    $0x10,%esp
80102603:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102606:	e9 9e 00 00 00       	jmp    801026a9 <namex+0xe5>
    ilock(ip);
8010260b:	83 ec 0c             	sub    $0xc,%esp
8010260e:	ff 75 f4             	pushl  -0xc(%ebp)
80102611:	e8 66 f5 ff ff       	call   80101b7c <ilock>
80102616:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010261c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102620:	66 83 f8 01          	cmp    $0x1,%ax
80102624:	74 18                	je     8010263e <namex+0x7a>
      iunlockput(ip);
80102626:	83 ec 0c             	sub    $0xc,%esp
80102629:	ff 75 f4             	pushl  -0xc(%ebp)
8010262c:	e8 88 f7 ff ff       	call   80101db9 <iunlockput>
80102631:	83 c4 10             	add    $0x10,%esp
      return 0;
80102634:	b8 00 00 00 00       	mov    $0x0,%eax
80102639:	e9 a7 00 00 00       	jmp    801026e5 <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
8010263e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102642:	74 20                	je     80102664 <namex+0xa0>
80102644:	8b 45 08             	mov    0x8(%ebp),%eax
80102647:	0f b6 00             	movzbl (%eax),%eax
8010264a:	84 c0                	test   %al,%al
8010264c:	75 16                	jne    80102664 <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
8010264e:	83 ec 0c             	sub    $0xc,%esp
80102651:	ff 75 f4             	pushl  -0xc(%ebp)
80102654:	e8 3a f6 ff ff       	call   80101c93 <iunlock>
80102659:	83 c4 10             	add    $0x10,%esp
      return ip;
8010265c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265f:	e9 81 00 00 00       	jmp    801026e5 <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102664:	83 ec 04             	sub    $0x4,%esp
80102667:	6a 00                	push   $0x0
80102669:	ff 75 10             	pushl  0x10(%ebp)
8010266c:	ff 75 f4             	pushl  -0xc(%ebp)
8010266f:	e8 12 fd ff ff       	call   80102386 <dirlookup>
80102674:	83 c4 10             	add    $0x10,%esp
80102677:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010267a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010267e:	75 15                	jne    80102695 <namex+0xd1>
      iunlockput(ip);
80102680:	83 ec 0c             	sub    $0xc,%esp
80102683:	ff 75 f4             	pushl  -0xc(%ebp)
80102686:	e8 2e f7 ff ff       	call   80101db9 <iunlockput>
8010268b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010268e:	b8 00 00 00 00       	mov    $0x0,%eax
80102693:	eb 50                	jmp    801026e5 <namex+0x121>
    }
    iunlockput(ip);
80102695:	83 ec 0c             	sub    $0xc,%esp
80102698:	ff 75 f4             	pushl  -0xc(%ebp)
8010269b:	e8 19 f7 ff ff       	call   80101db9 <iunlockput>
801026a0:	83 c4 10             	add    $0x10,%esp
    ip = next;
801026a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801026a9:	83 ec 08             	sub    $0x8,%esp
801026ac:	ff 75 10             	pushl  0x10(%ebp)
801026af:	ff 75 08             	pushl  0x8(%ebp)
801026b2:	e8 69 fe ff ff       	call   80102520 <skipelem>
801026b7:	83 c4 10             	add    $0x10,%esp
801026ba:	89 45 08             	mov    %eax,0x8(%ebp)
801026bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c1:	0f 85 44 ff ff ff    	jne    8010260b <namex+0x47>
  }
  if(nameiparent){
801026c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026cb:	74 15                	je     801026e2 <namex+0x11e>
    iput(ip);
801026cd:	83 ec 0c             	sub    $0xc,%esp
801026d0:	ff 75 f4             	pushl  -0xc(%ebp)
801026d3:	e8 0d f6 ff ff       	call   80101ce5 <iput>
801026d8:	83 c4 10             	add    $0x10,%esp
    return 0;
801026db:	b8 00 00 00 00       	mov    $0x0,%eax
801026e0:	eb 03                	jmp    801026e5 <namex+0x121>
  }
  return ip;
801026e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026e5:	c9                   	leave  
801026e6:	c3                   	ret    

801026e7 <namei>:

struct inode*
namei(char *path)
{
801026e7:	f3 0f 1e fb          	endbr32 
801026eb:	55                   	push   %ebp
801026ec:	89 e5                	mov    %esp,%ebp
801026ee:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026f1:	83 ec 04             	sub    $0x4,%esp
801026f4:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026f7:	50                   	push   %eax
801026f8:	6a 00                	push   $0x0
801026fa:	ff 75 08             	pushl  0x8(%ebp)
801026fd:	e8 c2 fe ff ff       	call   801025c4 <namex>
80102702:	83 c4 10             	add    $0x10,%esp
}
80102705:	c9                   	leave  
80102706:	c3                   	ret    

80102707 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102707:	f3 0f 1e fb          	endbr32 
8010270b:	55                   	push   %ebp
8010270c:	89 e5                	mov    %esp,%ebp
8010270e:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102711:	83 ec 04             	sub    $0x4,%esp
80102714:	ff 75 0c             	pushl  0xc(%ebp)
80102717:	6a 01                	push   $0x1
80102719:	ff 75 08             	pushl  0x8(%ebp)
8010271c:	e8 a3 fe ff ff       	call   801025c4 <namex>
80102721:	83 c4 10             	add    $0x10,%esp
}
80102724:	c9                   	leave  
80102725:	c3                   	ret    

80102726 <inb>:
{
80102726:	55                   	push   %ebp
80102727:	89 e5                	mov    %esp,%ebp
80102729:	83 ec 14             	sub    $0x14,%esp
8010272c:	8b 45 08             	mov    0x8(%ebp),%eax
8010272f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102733:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102737:	89 c2                	mov    %eax,%edx
80102739:	ec                   	in     (%dx),%al
8010273a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010273d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102741:	c9                   	leave  
80102742:	c3                   	ret    

80102743 <insl>:
{
80102743:	55                   	push   %ebp
80102744:	89 e5                	mov    %esp,%ebp
80102746:	57                   	push   %edi
80102747:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102748:	8b 55 08             	mov    0x8(%ebp),%edx
8010274b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010274e:	8b 45 10             	mov    0x10(%ebp),%eax
80102751:	89 cb                	mov    %ecx,%ebx
80102753:	89 df                	mov    %ebx,%edi
80102755:	89 c1                	mov    %eax,%ecx
80102757:	fc                   	cld    
80102758:	f3 6d                	rep insl (%dx),%es:(%edi)
8010275a:	89 c8                	mov    %ecx,%eax
8010275c:	89 fb                	mov    %edi,%ebx
8010275e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102761:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102764:	90                   	nop
80102765:	5b                   	pop    %ebx
80102766:	5f                   	pop    %edi
80102767:	5d                   	pop    %ebp
80102768:	c3                   	ret    

80102769 <outb>:
{
80102769:	55                   	push   %ebp
8010276a:	89 e5                	mov    %esp,%ebp
8010276c:	83 ec 08             	sub    $0x8,%esp
8010276f:	8b 45 08             	mov    0x8(%ebp),%eax
80102772:	8b 55 0c             	mov    0xc(%ebp),%edx
80102775:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102779:	89 d0                	mov    %edx,%eax
8010277b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010277e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102782:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102786:	ee                   	out    %al,(%dx)
}
80102787:	90                   	nop
80102788:	c9                   	leave  
80102789:	c3                   	ret    

8010278a <outsl>:
{
8010278a:	55                   	push   %ebp
8010278b:	89 e5                	mov    %esp,%ebp
8010278d:	56                   	push   %esi
8010278e:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010278f:	8b 55 08             	mov    0x8(%ebp),%edx
80102792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102795:	8b 45 10             	mov    0x10(%ebp),%eax
80102798:	89 cb                	mov    %ecx,%ebx
8010279a:	89 de                	mov    %ebx,%esi
8010279c:	89 c1                	mov    %eax,%ecx
8010279e:	fc                   	cld    
8010279f:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027a1:	89 c8                	mov    %ecx,%eax
801027a3:	89 f3                	mov    %esi,%ebx
801027a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027a8:	89 45 10             	mov    %eax,0x10(%ebp)
}
801027ab:	90                   	nop
801027ac:	5b                   	pop    %ebx
801027ad:	5e                   	pop    %esi
801027ae:	5d                   	pop    %ebp
801027af:	c3                   	ret    

801027b0 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027b0:	f3 0f 1e fb          	endbr32 
801027b4:	55                   	push   %ebp
801027b5:	89 e5                	mov    %esp,%ebp
801027b7:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027ba:	90                   	nop
801027bb:	68 f7 01 00 00       	push   $0x1f7
801027c0:	e8 61 ff ff ff       	call   80102726 <inb>
801027c5:	83 c4 04             	add    $0x4,%esp
801027c8:	0f b6 c0             	movzbl %al,%eax
801027cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027d1:	25 c0 00 00 00       	and    $0xc0,%eax
801027d6:	83 f8 40             	cmp    $0x40,%eax
801027d9:	75 e0                	jne    801027bb <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027df:	74 11                	je     801027f2 <idewait+0x42>
801027e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027e4:	83 e0 21             	and    $0x21,%eax
801027e7:	85 c0                	test   %eax,%eax
801027e9:	74 07                	je     801027f2 <idewait+0x42>
    return -1;
801027eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027f0:	eb 05                	jmp    801027f7 <idewait+0x47>
  return 0;
801027f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027f7:	c9                   	leave  
801027f8:	c3                   	ret    

801027f9 <ideinit>:

void
ideinit(void)
{
801027f9:	f3 0f 1e fb          	endbr32 
801027fd:	55                   	push   %ebp
801027fe:	89 e5                	mov    %esp,%ebp
80102800:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80102803:	83 ec 08             	sub    $0x8,%esp
80102806:	68 53 97 10 80       	push   $0x80109753
8010280b:	68 00 d6 10 80       	push   $0x8010d600
80102810:	e8 74 2c 00 00       	call   80105489 <initlock>
80102815:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102818:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
8010281d:	83 e8 01             	sub    $0x1,%eax
80102820:	83 ec 08             	sub    $0x8,%esp
80102823:	50                   	push   %eax
80102824:	6a 0e                	push   $0xe
80102826:	e8 bb 04 00 00       	call   80102ce6 <ioapicenable>
8010282b:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010282e:	83 ec 0c             	sub    $0xc,%esp
80102831:	6a 00                	push   $0x0
80102833:	e8 78 ff ff ff       	call   801027b0 <idewait>
80102838:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010283b:	83 ec 08             	sub    $0x8,%esp
8010283e:	68 f0 00 00 00       	push   $0xf0
80102843:	68 f6 01 00 00       	push   $0x1f6
80102848:	e8 1c ff ff ff       	call   80102769 <outb>
8010284d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102857:	eb 24                	jmp    8010287d <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102859:	83 ec 0c             	sub    $0xc,%esp
8010285c:	68 f7 01 00 00       	push   $0x1f7
80102861:	e8 c0 fe ff ff       	call   80102726 <inb>
80102866:	83 c4 10             	add    $0x10,%esp
80102869:	84 c0                	test   %al,%al
8010286b:	74 0c                	je     80102879 <ideinit+0x80>
      havedisk1 = 1;
8010286d:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
80102874:	00 00 00 
      break;
80102877:	eb 0d                	jmp    80102886 <ideinit+0x8d>
  for(i=0; i<1000; i++){
80102879:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010287d:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102884:	7e d3                	jle    80102859 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102886:	83 ec 08             	sub    $0x8,%esp
80102889:	68 e0 00 00 00       	push   $0xe0
8010288e:	68 f6 01 00 00       	push   $0x1f6
80102893:	e8 d1 fe ff ff       	call   80102769 <outb>
80102898:	83 c4 10             	add    $0x10,%esp
}
8010289b:	90                   	nop
8010289c:	c9                   	leave  
8010289d:	c3                   	ret    

8010289e <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010289e:	f3 0f 1e fb          	endbr32 
801028a2:	55                   	push   %ebp
801028a3:	89 e5                	mov    %esp,%ebp
801028a5:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801028a8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028ac:	75 0d                	jne    801028bb <idestart+0x1d>
    panic("idestart");
801028ae:	83 ec 0c             	sub    $0xc,%esp
801028b1:	68 57 97 10 80       	push   $0x80109757
801028b6:	e8 4d dd ff ff       	call   80100608 <panic>
  if(b->blockno >= FSSIZE)
801028bb:	8b 45 08             	mov    0x8(%ebp),%eax
801028be:	8b 40 08             	mov    0x8(%eax),%eax
801028c1:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028c6:	76 0d                	jbe    801028d5 <idestart+0x37>
    panic("incorrect blockno");
801028c8:	83 ec 0c             	sub    $0xc,%esp
801028cb:	68 60 97 10 80       	push   $0x80109760
801028d0:	e8 33 dd ff ff       	call   80100608 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801028d5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028dc:	8b 45 08             	mov    0x8(%ebp),%eax
801028df:	8b 50 08             	mov    0x8(%eax),%edx
801028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e5:	0f af c2             	imul   %edx,%eax
801028e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028eb:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028ef:	75 07                	jne    801028f8 <idestart+0x5a>
801028f1:	b8 20 00 00 00       	mov    $0x20,%eax
801028f6:	eb 05                	jmp    801028fd <idestart+0x5f>
801028f8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102900:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102904:	75 07                	jne    8010290d <idestart+0x6f>
80102906:	b8 30 00 00 00       	mov    $0x30,%eax
8010290b:	eb 05                	jmp    80102912 <idestart+0x74>
8010290d:	b8 c5 00 00 00       	mov    $0xc5,%eax
80102912:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102915:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102919:	7e 0d                	jle    80102928 <idestart+0x8a>
8010291b:	83 ec 0c             	sub    $0xc,%esp
8010291e:	68 57 97 10 80       	push   $0x80109757
80102923:	e8 e0 dc ff ff       	call   80100608 <panic>

  idewait(0);
80102928:	83 ec 0c             	sub    $0xc,%esp
8010292b:	6a 00                	push   $0x0
8010292d:	e8 7e fe ff ff       	call   801027b0 <idewait>
80102932:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102935:	83 ec 08             	sub    $0x8,%esp
80102938:	6a 00                	push   $0x0
8010293a:	68 f6 03 00 00       	push   $0x3f6
8010293f:	e8 25 fe ff ff       	call   80102769 <outb>
80102944:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294a:	0f b6 c0             	movzbl %al,%eax
8010294d:	83 ec 08             	sub    $0x8,%esp
80102950:	50                   	push   %eax
80102951:	68 f2 01 00 00       	push   $0x1f2
80102956:	e8 0e fe ff ff       	call   80102769 <outb>
8010295b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010295e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102961:	0f b6 c0             	movzbl %al,%eax
80102964:	83 ec 08             	sub    $0x8,%esp
80102967:	50                   	push   %eax
80102968:	68 f3 01 00 00       	push   $0x1f3
8010296d:	e8 f7 fd ff ff       	call   80102769 <outb>
80102972:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102975:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102978:	c1 f8 08             	sar    $0x8,%eax
8010297b:	0f b6 c0             	movzbl %al,%eax
8010297e:	83 ec 08             	sub    $0x8,%esp
80102981:	50                   	push   %eax
80102982:	68 f4 01 00 00       	push   $0x1f4
80102987:	e8 dd fd ff ff       	call   80102769 <outb>
8010298c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010298f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102992:	c1 f8 10             	sar    $0x10,%eax
80102995:	0f b6 c0             	movzbl %al,%eax
80102998:	83 ec 08             	sub    $0x8,%esp
8010299b:	50                   	push   %eax
8010299c:	68 f5 01 00 00       	push   $0x1f5
801029a1:	e8 c3 fd ff ff       	call   80102769 <outb>
801029a6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801029a9:	8b 45 08             	mov    0x8(%ebp),%eax
801029ac:	8b 40 04             	mov    0x4(%eax),%eax
801029af:	c1 e0 04             	shl    $0x4,%eax
801029b2:	83 e0 10             	and    $0x10,%eax
801029b5:	89 c2                	mov    %eax,%edx
801029b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029ba:	c1 f8 18             	sar    $0x18,%eax
801029bd:	83 e0 0f             	and    $0xf,%eax
801029c0:	09 d0                	or     %edx,%eax
801029c2:	83 c8 e0             	or     $0xffffffe0,%eax
801029c5:	0f b6 c0             	movzbl %al,%eax
801029c8:	83 ec 08             	sub    $0x8,%esp
801029cb:	50                   	push   %eax
801029cc:	68 f6 01 00 00       	push   $0x1f6
801029d1:	e8 93 fd ff ff       	call   80102769 <outb>
801029d6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801029d9:	8b 45 08             	mov    0x8(%ebp),%eax
801029dc:	8b 00                	mov    (%eax),%eax
801029de:	83 e0 04             	and    $0x4,%eax
801029e1:	85 c0                	test   %eax,%eax
801029e3:	74 35                	je     80102a1a <idestart+0x17c>
    outb(0x1f7, write_cmd);
801029e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029e8:	0f b6 c0             	movzbl %al,%eax
801029eb:	83 ec 08             	sub    $0x8,%esp
801029ee:	50                   	push   %eax
801029ef:	68 f7 01 00 00       	push   $0x1f7
801029f4:	e8 70 fd ff ff       	call   80102769 <outb>
801029f9:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801029fc:	8b 45 08             	mov    0x8(%ebp),%eax
801029ff:	83 c0 5c             	add    $0x5c,%eax
80102a02:	83 ec 04             	sub    $0x4,%esp
80102a05:	68 80 00 00 00       	push   $0x80
80102a0a:	50                   	push   %eax
80102a0b:	68 f0 01 00 00       	push   $0x1f0
80102a10:	e8 75 fd ff ff       	call   8010278a <outsl>
80102a15:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102a18:	eb 17                	jmp    80102a31 <idestart+0x193>
    outb(0x1f7, read_cmd);
80102a1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a1d:	0f b6 c0             	movzbl %al,%eax
80102a20:	83 ec 08             	sub    $0x8,%esp
80102a23:	50                   	push   %eax
80102a24:	68 f7 01 00 00       	push   $0x1f7
80102a29:	e8 3b fd ff ff       	call   80102769 <outb>
80102a2e:	83 c4 10             	add    $0x10,%esp
}
80102a31:	90                   	nop
80102a32:	c9                   	leave  
80102a33:	c3                   	ret    

80102a34 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a34:	f3 0f 1e fb          	endbr32 
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
80102a3b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a3e:	83 ec 0c             	sub    $0xc,%esp
80102a41:	68 00 d6 10 80       	push   $0x8010d600
80102a46:	e8 64 2a 00 00       	call   801054af <acquire>
80102a4b:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102a4e:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102a53:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a56:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a5a:	75 15                	jne    80102a71 <ideintr+0x3d>
    release(&idelock);
80102a5c:	83 ec 0c             	sub    $0xc,%esp
80102a5f:	68 00 d6 10 80       	push   $0x8010d600
80102a64:	e8 b8 2a 00 00       	call   80105521 <release>
80102a69:	83 c4 10             	add    $0x10,%esp
    return;
80102a6c:	e9 9a 00 00 00       	jmp    80102b0b <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a74:	8b 40 58             	mov    0x58(%eax),%eax
80102a77:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7f:	8b 00                	mov    (%eax),%eax
80102a81:	83 e0 04             	and    $0x4,%eax
80102a84:	85 c0                	test   %eax,%eax
80102a86:	75 2d                	jne    80102ab5 <ideintr+0x81>
80102a88:	83 ec 0c             	sub    $0xc,%esp
80102a8b:	6a 01                	push   $0x1
80102a8d:	e8 1e fd ff ff       	call   801027b0 <idewait>
80102a92:	83 c4 10             	add    $0x10,%esp
80102a95:	85 c0                	test   %eax,%eax
80102a97:	78 1c                	js     80102ab5 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
80102a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9c:	83 c0 5c             	add    $0x5c,%eax
80102a9f:	83 ec 04             	sub    $0x4,%esp
80102aa2:	68 80 00 00 00       	push   $0x80
80102aa7:	50                   	push   %eax
80102aa8:	68 f0 01 00 00       	push   $0x1f0
80102aad:	e8 91 fc ff ff       	call   80102743 <insl>
80102ab2:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab8:	8b 00                	mov    (%eax),%eax
80102aba:	83 c8 02             	or     $0x2,%eax
80102abd:	89 c2                	mov    %eax,%edx
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac7:	8b 00                	mov    (%eax),%eax
80102ac9:	83 e0 fb             	and    $0xfffffffb,%eax
80102acc:	89 c2                	mov    %eax,%edx
80102ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102ad3:	83 ec 0c             	sub    $0xc,%esp
80102ad6:	ff 75 f4             	pushl  -0xc(%ebp)
80102ad9:	e8 51 26 00 00       	call   8010512f <wakeup>
80102ade:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102ae1:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102ae6:	85 c0                	test   %eax,%eax
80102ae8:	74 11                	je     80102afb <ideintr+0xc7>
    idestart(idequeue);
80102aea:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102aef:	83 ec 0c             	sub    $0xc,%esp
80102af2:	50                   	push   %eax
80102af3:	e8 a6 fd ff ff       	call   8010289e <idestart>
80102af8:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102afb:	83 ec 0c             	sub    $0xc,%esp
80102afe:	68 00 d6 10 80       	push   $0x8010d600
80102b03:	e8 19 2a 00 00       	call   80105521 <release>
80102b08:	83 c4 10             	add    $0x10,%esp
}
80102b0b:	c9                   	leave  
80102b0c:	c3                   	ret    

80102b0d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b0d:	f3 0f 1e fb          	endbr32 
80102b11:	55                   	push   %ebp
80102b12:	89 e5                	mov    %esp,%ebp
80102b14:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b17:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1a:	83 c0 0c             	add    $0xc,%eax
80102b1d:	83 ec 0c             	sub    $0xc,%esp
80102b20:	50                   	push   %eax
80102b21:	e8 ca 28 00 00       	call   801053f0 <holdingsleep>
80102b26:	83 c4 10             	add    $0x10,%esp
80102b29:	85 c0                	test   %eax,%eax
80102b2b:	75 0d                	jne    80102b3a <iderw+0x2d>
    panic("iderw: buf not locked");
80102b2d:	83 ec 0c             	sub    $0xc,%esp
80102b30:	68 72 97 10 80       	push   $0x80109772
80102b35:	e8 ce da ff ff       	call   80100608 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3d:	8b 00                	mov    (%eax),%eax
80102b3f:	83 e0 06             	and    $0x6,%eax
80102b42:	83 f8 02             	cmp    $0x2,%eax
80102b45:	75 0d                	jne    80102b54 <iderw+0x47>
    panic("iderw: nothing to do");
80102b47:	83 ec 0c             	sub    $0xc,%esp
80102b4a:	68 88 97 10 80       	push   $0x80109788
80102b4f:	e8 b4 da ff ff       	call   80100608 <panic>
  if(b->dev != 0 && !havedisk1)
80102b54:	8b 45 08             	mov    0x8(%ebp),%eax
80102b57:	8b 40 04             	mov    0x4(%eax),%eax
80102b5a:	85 c0                	test   %eax,%eax
80102b5c:	74 16                	je     80102b74 <iderw+0x67>
80102b5e:	a1 38 d6 10 80       	mov    0x8010d638,%eax
80102b63:	85 c0                	test   %eax,%eax
80102b65:	75 0d                	jne    80102b74 <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102b67:	83 ec 0c             	sub    $0xc,%esp
80102b6a:	68 9d 97 10 80       	push   $0x8010979d
80102b6f:	e8 94 da ff ff       	call   80100608 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b74:	83 ec 0c             	sub    $0xc,%esp
80102b77:	68 00 d6 10 80       	push   $0x8010d600
80102b7c:	e8 2e 29 00 00       	call   801054af <acquire>
80102b81:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102b84:	8b 45 08             	mov    0x8(%ebp),%eax
80102b87:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b8e:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
80102b95:	eb 0b                	jmp    80102ba2 <iderw+0x95>
80102b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9a:	8b 00                	mov    (%eax),%eax
80102b9c:	83 c0 58             	add    $0x58,%eax
80102b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba5:	8b 00                	mov    (%eax),%eax
80102ba7:	85 c0                	test   %eax,%eax
80102ba9:	75 ec                	jne    80102b97 <iderw+0x8a>
    ;
  *pp = b;
80102bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bae:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb1:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102bb3:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80102bb8:	39 45 08             	cmp    %eax,0x8(%ebp)
80102bbb:	75 23                	jne    80102be0 <iderw+0xd3>
    idestart(b);
80102bbd:	83 ec 0c             	sub    $0xc,%esp
80102bc0:	ff 75 08             	pushl  0x8(%ebp)
80102bc3:	e8 d6 fc ff ff       	call   8010289e <idestart>
80102bc8:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bcb:	eb 13                	jmp    80102be0 <iderw+0xd3>
    sleep(b, &idelock);
80102bcd:	83 ec 08             	sub    $0x8,%esp
80102bd0:	68 00 d6 10 80       	push   $0x8010d600
80102bd5:	ff 75 08             	pushl  0x8(%ebp)
80102bd8:	e8 60 24 00 00       	call   8010503d <sleep>
80102bdd:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102be0:	8b 45 08             	mov    0x8(%ebp),%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	83 e0 06             	and    $0x6,%eax
80102be8:	83 f8 02             	cmp    $0x2,%eax
80102beb:	75 e0                	jne    80102bcd <iderw+0xc0>
  }


  release(&idelock);
80102bed:	83 ec 0c             	sub    $0xc,%esp
80102bf0:	68 00 d6 10 80       	push   $0x8010d600
80102bf5:	e8 27 29 00 00       	call   80105521 <release>
80102bfa:	83 c4 10             	add    $0x10,%esp
}
80102bfd:	90                   	nop
80102bfe:	c9                   	leave  
80102bff:	c3                   	ret    

80102c00 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102c00:	f3 0f 1e fb          	endbr32 
80102c04:	55                   	push   %ebp
80102c05:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c07:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c0c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c0f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c11:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c16:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c19:	5d                   	pop    %ebp
80102c1a:	c3                   	ret    

80102c1b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c1b:	f3 0f 1e fb          	endbr32 
80102c1f:	55                   	push   %ebp
80102c20:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c22:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c27:	8b 55 08             	mov    0x8(%ebp),%edx
80102c2a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c2c:	a1 d4 56 11 80       	mov    0x801156d4,%eax
80102c31:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c34:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c37:	90                   	nop
80102c38:	5d                   	pop    %ebp
80102c39:	c3                   	ret    

80102c3a <ioapicinit>:

void
ioapicinit(void)
{
80102c3a:	f3 0f 1e fb          	endbr32 
80102c3e:	55                   	push   %ebp
80102c3f:	89 e5                	mov    %esp,%ebp
80102c41:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c44:	c7 05 d4 56 11 80 00 	movl   $0xfec00000,0x801156d4
80102c4b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c4e:	6a 01                	push   $0x1
80102c50:	e8 ab ff ff ff       	call   80102c00 <ioapicread>
80102c55:	83 c4 04             	add    $0x4,%esp
80102c58:	c1 e8 10             	shr    $0x10,%eax
80102c5b:	25 ff 00 00 00       	and    $0xff,%eax
80102c60:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c63:	6a 00                	push   $0x0
80102c65:	e8 96 ff ff ff       	call   80102c00 <ioapicread>
80102c6a:	83 c4 04             	add    $0x4,%esp
80102c6d:	c1 e8 18             	shr    $0x18,%eax
80102c70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c73:	0f b6 05 00 58 11 80 	movzbl 0x80115800,%eax
80102c7a:	0f b6 c0             	movzbl %al,%eax
80102c7d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102c80:	74 10                	je     80102c92 <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c82:	83 ec 0c             	sub    $0xc,%esp
80102c85:	68 bc 97 10 80       	push   $0x801097bc
80102c8a:	e8 89 d7 ff ff       	call   80100418 <cprintf>
80102c8f:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c99:	eb 3f                	jmp    80102cda <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c9e:	83 c0 20             	add    $0x20,%eax
80102ca1:	0d 00 00 01 00       	or     $0x10000,%eax
80102ca6:	89 c2                	mov    %eax,%edx
80102ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cab:	83 c0 08             	add    $0x8,%eax
80102cae:	01 c0                	add    %eax,%eax
80102cb0:	83 ec 08             	sub    $0x8,%esp
80102cb3:	52                   	push   %edx
80102cb4:	50                   	push   %eax
80102cb5:	e8 61 ff ff ff       	call   80102c1b <ioapicwrite>
80102cba:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc0:	83 c0 08             	add    $0x8,%eax
80102cc3:	01 c0                	add    %eax,%eax
80102cc5:	83 c0 01             	add    $0x1,%eax
80102cc8:	83 ec 08             	sub    $0x8,%esp
80102ccb:	6a 00                	push   $0x0
80102ccd:	50                   	push   %eax
80102cce:	e8 48 ff ff ff       	call   80102c1b <ioapicwrite>
80102cd3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102cd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cdd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ce0:	7e b9                	jle    80102c9b <ioapicinit+0x61>
  }
}
80102ce2:	90                   	nop
80102ce3:	90                   	nop
80102ce4:	c9                   	leave  
80102ce5:	c3                   	ret    

80102ce6 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ce6:	f3 0f 1e fb          	endbr32 
80102cea:	55                   	push   %ebp
80102ceb:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ced:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf0:	83 c0 20             	add    $0x20,%eax
80102cf3:	89 c2                	mov    %eax,%edx
80102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf8:	83 c0 08             	add    $0x8,%eax
80102cfb:	01 c0                	add    %eax,%eax
80102cfd:	52                   	push   %edx
80102cfe:	50                   	push   %eax
80102cff:	e8 17 ff ff ff       	call   80102c1b <ioapicwrite>
80102d04:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d0a:	c1 e0 18             	shl    $0x18,%eax
80102d0d:	89 c2                	mov    %eax,%edx
80102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d12:	83 c0 08             	add    $0x8,%eax
80102d15:	01 c0                	add    %eax,%eax
80102d17:	83 c0 01             	add    $0x1,%eax
80102d1a:	52                   	push   %edx
80102d1b:	50                   	push   %eax
80102d1c:	e8 fa fe ff ff       	call   80102c1b <ioapicwrite>
80102d21:	83 c4 08             	add    $0x8,%esp
}
80102d24:	90                   	nop
80102d25:	c9                   	leave  
80102d26:	c3                   	ret    

80102d27 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d27:	f3 0f 1e fb          	endbr32 
80102d2b:	55                   	push   %ebp
80102d2c:	89 e5                	mov    %esp,%ebp
80102d2e:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102d31:	83 ec 08             	sub    $0x8,%esp
80102d34:	68 f0 97 10 80       	push   $0x801097f0
80102d39:	68 e0 56 11 80       	push   $0x801156e0
80102d3e:	e8 46 27 00 00       	call   80105489 <initlock>
80102d43:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102d46:	c7 05 14 57 11 80 00 	movl   $0x0,0x80115714
80102d4d:	00 00 00 
  freerange(vstart, vend);
80102d50:	83 ec 08             	sub    $0x8,%esp
80102d53:	ff 75 0c             	pushl  0xc(%ebp)
80102d56:	ff 75 08             	pushl  0x8(%ebp)
80102d59:	e8 2e 00 00 00       	call   80102d8c <freerange>
80102d5e:	83 c4 10             	add    $0x10,%esp
}
80102d61:	90                   	nop
80102d62:	c9                   	leave  
80102d63:	c3                   	ret    

80102d64 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d64:	f3 0f 1e fb          	endbr32 
80102d68:	55                   	push   %ebp
80102d69:	89 e5                	mov    %esp,%ebp
80102d6b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102d6e:	83 ec 08             	sub    $0x8,%esp
80102d71:	ff 75 0c             	pushl  0xc(%ebp)
80102d74:	ff 75 08             	pushl  0x8(%ebp)
80102d77:	e8 10 00 00 00       	call   80102d8c <freerange>
80102d7c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102d7f:	c7 05 14 57 11 80 01 	movl   $0x1,0x80115714
80102d86:	00 00 00 
}
80102d89:	90                   	nop
80102d8a:	c9                   	leave  
80102d8b:	c3                   	ret    

80102d8c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d8c:	f3 0f 1e fb          	endbr32 
80102d90:	55                   	push   %ebp
80102d91:	89 e5                	mov    %esp,%ebp
80102d93:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d96:	8b 45 08             	mov    0x8(%ebp),%eax
80102d99:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102da6:	eb 15                	jmp    80102dbd <freerange+0x31>
    kfree(p);
80102da8:	83 ec 0c             	sub    $0xc,%esp
80102dab:	ff 75 f4             	pushl  -0xc(%ebp)
80102dae:	e8 1b 00 00 00       	call   80102dce <kfree>
80102db3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102db6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dc0:	05 00 10 00 00       	add    $0x1000,%eax
80102dc5:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102dc8:	73 de                	jae    80102da8 <freerange+0x1c>
}
80102dca:	90                   	nop
80102dcb:	90                   	nop
80102dcc:	c9                   	leave  
80102dcd:	c3                   	ret    

80102dce <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102dce:	f3 0f 1e fb          	endbr32 
80102dd2:	55                   	push   %ebp
80102dd3:	89 e5                	mov    %esp,%ebp
80102dd5:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102dd8:	8b 45 08             	mov    0x8(%ebp),%eax
80102ddb:	25 ff 0f 00 00       	and    $0xfff,%eax
80102de0:	85 c0                	test   %eax,%eax
80102de2:	75 18                	jne    80102dfc <kfree+0x2e>
80102de4:	81 7d 08 48 8f 11 80 	cmpl   $0x80118f48,0x8(%ebp)
80102deb:	72 0f                	jb     80102dfc <kfree+0x2e>
80102ded:	8b 45 08             	mov    0x8(%ebp),%eax
80102df0:	05 00 00 00 80       	add    $0x80000000,%eax
80102df5:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dfa:	76 0d                	jbe    80102e09 <kfree+0x3b>
    panic("kfree");
80102dfc:	83 ec 0c             	sub    $0xc,%esp
80102dff:	68 f5 97 10 80       	push   $0x801097f5
80102e04:	e8 ff d7 ff ff       	call   80100608 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e09:	83 ec 04             	sub    $0x4,%esp
80102e0c:	68 00 10 00 00       	push   $0x1000
80102e11:	6a 01                	push   $0x1
80102e13:	ff 75 08             	pushl  0x8(%ebp)
80102e16:	e8 33 29 00 00       	call   8010574e <memset>
80102e1b:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102e1e:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e23:	85 c0                	test   %eax,%eax
80102e25:	74 10                	je     80102e37 <kfree+0x69>
    acquire(&kmem.lock);
80102e27:	83 ec 0c             	sub    $0xc,%esp
80102e2a:	68 e0 56 11 80       	push   $0x801156e0
80102e2f:	e8 7b 26 00 00       	call   801054af <acquire>
80102e34:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102e37:	8b 45 08             	mov    0x8(%ebp),%eax
80102e3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e3d:	8b 15 18 57 11 80    	mov    0x80115718,%edx
80102e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e46:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e4b:	a3 18 57 11 80       	mov    %eax,0x80115718
  if(kmem.use_lock)
80102e50:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	74 10                	je     80102e69 <kfree+0x9b>
    release(&kmem.lock);
80102e59:	83 ec 0c             	sub    $0xc,%esp
80102e5c:	68 e0 56 11 80       	push   $0x801156e0
80102e61:	e8 bb 26 00 00       	call   80105521 <release>
80102e66:	83 c4 10             	add    $0x10,%esp
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave  
80102e6b:	c3                   	ret    

80102e6c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e6c:	f3 0f 1e fb          	endbr32 
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102e76:	a1 14 57 11 80       	mov    0x80115714,%eax
80102e7b:	85 c0                	test   %eax,%eax
80102e7d:	74 10                	je     80102e8f <kalloc+0x23>
    acquire(&kmem.lock);
80102e7f:	83 ec 0c             	sub    $0xc,%esp
80102e82:	68 e0 56 11 80       	push   $0x801156e0
80102e87:	e8 23 26 00 00       	call   801054af <acquire>
80102e8c:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102e8f:	a1 18 57 11 80       	mov    0x80115718,%eax
80102e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e9b:	74 0a                	je     80102ea7 <kalloc+0x3b>
    kmem.freelist = r->next;
80102e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea0:	8b 00                	mov    (%eax),%eax
80102ea2:	a3 18 57 11 80       	mov    %eax,0x80115718
  if(kmem.use_lock)
80102ea7:	a1 14 57 11 80       	mov    0x80115714,%eax
80102eac:	85 c0                	test   %eax,%eax
80102eae:	74 10                	je     80102ec0 <kalloc+0x54>
    release(&kmem.lock);
80102eb0:	83 ec 0c             	sub    $0xc,%esp
80102eb3:	68 e0 56 11 80       	push   $0x801156e0
80102eb8:	e8 64 26 00 00       	call   80105521 <release>
80102ebd:	83 c4 10             	add    $0x10,%esp
  cprintf("p4Debug : kalloc returns %d %x\n", PPN(V2P(r)), V2P(r));
80102ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ec3:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ecc:	05 00 00 00 80       	add    $0x80000000,%eax
80102ed1:	c1 e8 0c             	shr    $0xc,%eax
80102ed4:	83 ec 04             	sub    $0x4,%esp
80102ed7:	52                   	push   %edx
80102ed8:	50                   	push   %eax
80102ed9:	68 fc 97 10 80       	push   $0x801097fc
80102ede:	e8 35 d5 ff ff       	call   80100418 <cprintf>
80102ee3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ee9:	c9                   	leave  
80102eea:	c3                   	ret    

80102eeb <inb>:
{
80102eeb:	55                   	push   %ebp
80102eec:	89 e5                	mov    %esp,%ebp
80102eee:	83 ec 14             	sub    $0x14,%esp
80102ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ef4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ef8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102efc:	89 c2                	mov    %eax,%edx
80102efe:	ec                   	in     (%dx),%al
80102eff:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f02:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f06:	c9                   	leave  
80102f07:	c3                   	ret    

80102f08 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102f08:	f3 0f 1e fb          	endbr32 
80102f0c:	55                   	push   %ebp
80102f0d:	89 e5                	mov    %esp,%ebp
80102f0f:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102f12:	6a 64                	push   $0x64
80102f14:	e8 d2 ff ff ff       	call   80102eeb <inb>
80102f19:	83 c4 04             	add    $0x4,%esp
80102f1c:	0f b6 c0             	movzbl %al,%eax
80102f1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f25:	83 e0 01             	and    $0x1,%eax
80102f28:	85 c0                	test   %eax,%eax
80102f2a:	75 0a                	jne    80102f36 <kbdgetc+0x2e>
    return -1;
80102f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f31:	e9 23 01 00 00       	jmp    80103059 <kbdgetc+0x151>
  data = inb(KBDATAP);
80102f36:	6a 60                	push   $0x60
80102f38:	e8 ae ff ff ff       	call   80102eeb <inb>
80102f3d:	83 c4 04             	add    $0x4,%esp
80102f40:	0f b6 c0             	movzbl %al,%eax
80102f43:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102f46:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102f4d:	75 17                	jne    80102f66 <kbdgetc+0x5e>
    shift |= E0ESC;
80102f4f:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f54:	83 c8 40             	or     $0x40,%eax
80102f57:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80102f5c:	b8 00 00 00 00       	mov    $0x0,%eax
80102f61:	e9 f3 00 00 00       	jmp    80103059 <kbdgetc+0x151>
  } else if(data & 0x80){
80102f66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f69:	25 80 00 00 00       	and    $0x80,%eax
80102f6e:	85 c0                	test   %eax,%eax
80102f70:	74 45                	je     80102fb7 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f72:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102f77:	83 e0 40             	and    $0x40,%eax
80102f7a:	85 c0                	test   %eax,%eax
80102f7c:	75 08                	jne    80102f86 <kbdgetc+0x7e>
80102f7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f81:	83 e0 7f             	and    $0x7f,%eax
80102f84:	eb 03                	jmp    80102f89 <kbdgetc+0x81>
80102f86:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f89:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f8f:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102f94:	0f b6 00             	movzbl (%eax),%eax
80102f97:	83 c8 40             	or     $0x40,%eax
80102f9a:	0f b6 c0             	movzbl %al,%eax
80102f9d:	f7 d0                	not    %eax
80102f9f:	89 c2                	mov    %eax,%edx
80102fa1:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fa6:	21 d0                	and    %edx,%eax
80102fa8:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
    return 0;
80102fad:	b8 00 00 00 00       	mov    $0x0,%eax
80102fb2:	e9 a2 00 00 00       	jmp    80103059 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102fb7:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fbc:	83 e0 40             	and    $0x40,%eax
80102fbf:	85 c0                	test   %eax,%eax
80102fc1:	74 14                	je     80102fd7 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102fc3:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102fca:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fcf:	83 e0 bf             	and    $0xffffffbf,%eax
80102fd2:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  }

  shift |= shiftcode[data];
80102fd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fda:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102fdf:	0f b6 00             	movzbl (%eax),%eax
80102fe2:	0f b6 d0             	movzbl %al,%edx
80102fe5:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80102fea:	09 d0                	or     %edx,%eax
80102fec:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  shift ^= togglecode[data];
80102ff1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ff4:	05 20 b1 10 80       	add    $0x8010b120,%eax
80102ff9:	0f b6 00             	movzbl (%eax),%eax
80102ffc:	0f b6 d0             	movzbl %al,%edx
80102fff:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103004:	31 d0                	xor    %edx,%eax
80103006:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  c = charcode[shift & (CTL | SHIFT)][data];
8010300b:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103010:	83 e0 03             	and    $0x3,%eax
80103013:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
8010301a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010301d:	01 d0                	add    %edx,%eax
8010301f:	0f b6 00             	movzbl (%eax),%eax
80103022:	0f b6 c0             	movzbl %al,%eax
80103025:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103028:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010302d:	83 e0 08             	and    $0x8,%eax
80103030:	85 c0                	test   %eax,%eax
80103032:	74 22                	je     80103056 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80103034:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103038:	76 0c                	jbe    80103046 <kbdgetc+0x13e>
8010303a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010303e:	77 06                	ja     80103046 <kbdgetc+0x13e>
      c += 'A' - 'a';
80103040:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80103044:	eb 10                	jmp    80103056 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80103046:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
8010304a:	76 0a                	jbe    80103056 <kbdgetc+0x14e>
8010304c:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80103050:	77 04                	ja     80103056 <kbdgetc+0x14e>
      c += 'a' - 'A';
80103052:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80103056:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103059:	c9                   	leave  
8010305a:	c3                   	ret    

8010305b <kbdintr>:

void
kbdintr(void)
{
8010305b:	f3 0f 1e fb          	endbr32 
8010305f:	55                   	push   %ebp
80103060:	89 e5                	mov    %esp,%ebp
80103062:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80103065:	83 ec 0c             	sub    $0xc,%esp
80103068:	68 08 2f 10 80       	push   $0x80102f08
8010306d:	e8 36 d8 ff ff       	call   801008a8 <consoleintr>
80103072:	83 c4 10             	add    $0x10,%esp
}
80103075:	90                   	nop
80103076:	c9                   	leave  
80103077:	c3                   	ret    

80103078 <inb>:
{
80103078:	55                   	push   %ebp
80103079:	89 e5                	mov    %esp,%ebp
8010307b:	83 ec 14             	sub    $0x14,%esp
8010307e:	8b 45 08             	mov    0x8(%ebp),%eax
80103081:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103085:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103089:	89 c2                	mov    %eax,%edx
8010308b:	ec                   	in     (%dx),%al
8010308c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010308f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103093:	c9                   	leave  
80103094:	c3                   	ret    

80103095 <outb>:
{
80103095:	55                   	push   %ebp
80103096:	89 e5                	mov    %esp,%ebp
80103098:	83 ec 08             	sub    $0x8,%esp
8010309b:	8b 45 08             	mov    0x8(%ebp),%eax
8010309e:	8b 55 0c             	mov    0xc(%ebp),%edx
801030a1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801030a5:	89 d0                	mov    %edx,%eax
801030a7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801030aa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801030ae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801030b2:	ee                   	out    %al,(%dx)
}
801030b3:	90                   	nop
801030b4:	c9                   	leave  
801030b5:	c3                   	ret    

801030b6 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801030b6:	f3 0f 1e fb          	endbr32 
801030ba:	55                   	push   %ebp
801030bb:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801030bd:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030c2:	8b 55 08             	mov    0x8(%ebp),%edx
801030c5:	c1 e2 02             	shl    $0x2,%edx
801030c8:	01 c2                	add    %eax,%edx
801030ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801030cd:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801030cf:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030d4:	83 c0 20             	add    $0x20,%eax
801030d7:	8b 00                	mov    (%eax),%eax
}
801030d9:	90                   	nop
801030da:	5d                   	pop    %ebp
801030db:	c3                   	ret    

801030dc <lapicinit>:

void
lapicinit(void)
{
801030dc:	f3 0f 1e fb          	endbr32 
801030e0:	55                   	push   %ebp
801030e1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801030e3:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801030e8:	85 c0                	test   %eax,%eax
801030ea:	0f 84 0c 01 00 00    	je     801031fc <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801030f0:	68 3f 01 00 00       	push   $0x13f
801030f5:	6a 3c                	push   $0x3c
801030f7:	e8 ba ff ff ff       	call   801030b6 <lapicw>
801030fc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801030ff:	6a 0b                	push   $0xb
80103101:	68 f8 00 00 00       	push   $0xf8
80103106:	e8 ab ff ff ff       	call   801030b6 <lapicw>
8010310b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010310e:	68 20 00 02 00       	push   $0x20020
80103113:	68 c8 00 00 00       	push   $0xc8
80103118:	e8 99 ff ff ff       	call   801030b6 <lapicw>
8010311d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103120:	68 80 96 98 00       	push   $0x989680
80103125:	68 e0 00 00 00       	push   $0xe0
8010312a:	e8 87 ff ff ff       	call   801030b6 <lapicw>
8010312f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103132:	68 00 00 01 00       	push   $0x10000
80103137:	68 d4 00 00 00       	push   $0xd4
8010313c:	e8 75 ff ff ff       	call   801030b6 <lapicw>
80103141:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103144:	68 00 00 01 00       	push   $0x10000
80103149:	68 d8 00 00 00       	push   $0xd8
8010314e:	e8 63 ff ff ff       	call   801030b6 <lapicw>
80103153:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103156:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010315b:	83 c0 30             	add    $0x30,%eax
8010315e:	8b 00                	mov    (%eax),%eax
80103160:	c1 e8 10             	shr    $0x10,%eax
80103163:	25 fc 00 00 00       	and    $0xfc,%eax
80103168:	85 c0                	test   %eax,%eax
8010316a:	74 12                	je     8010317e <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
8010316c:	68 00 00 01 00       	push   $0x10000
80103171:	68 d0 00 00 00       	push   $0xd0
80103176:	e8 3b ff ff ff       	call   801030b6 <lapicw>
8010317b:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010317e:	6a 33                	push   $0x33
80103180:	68 dc 00 00 00       	push   $0xdc
80103185:	e8 2c ff ff ff       	call   801030b6 <lapicw>
8010318a:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010318d:	6a 00                	push   $0x0
8010318f:	68 a0 00 00 00       	push   $0xa0
80103194:	e8 1d ff ff ff       	call   801030b6 <lapicw>
80103199:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010319c:	6a 00                	push   $0x0
8010319e:	68 a0 00 00 00       	push   $0xa0
801031a3:	e8 0e ff ff ff       	call   801030b6 <lapicw>
801031a8:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801031ab:	6a 00                	push   $0x0
801031ad:	6a 2c                	push   $0x2c
801031af:	e8 02 ff ff ff       	call   801030b6 <lapicw>
801031b4:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801031b7:	6a 00                	push   $0x0
801031b9:	68 c4 00 00 00       	push   $0xc4
801031be:	e8 f3 fe ff ff       	call   801030b6 <lapicw>
801031c3:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801031c6:	68 00 85 08 00       	push   $0x88500
801031cb:	68 c0 00 00 00       	push   $0xc0
801031d0:	e8 e1 fe ff ff       	call   801030b6 <lapicw>
801031d5:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801031d8:	90                   	nop
801031d9:	a1 1c 57 11 80       	mov    0x8011571c,%eax
801031de:	05 00 03 00 00       	add    $0x300,%eax
801031e3:	8b 00                	mov    (%eax),%eax
801031e5:	25 00 10 00 00       	and    $0x1000,%eax
801031ea:	85 c0                	test   %eax,%eax
801031ec:	75 eb                	jne    801031d9 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031ee:	6a 00                	push   $0x0
801031f0:	6a 20                	push   $0x20
801031f2:	e8 bf fe ff ff       	call   801030b6 <lapicw>
801031f7:	83 c4 08             	add    $0x8,%esp
801031fa:	eb 01                	jmp    801031fd <lapicinit+0x121>
    return;
801031fc:	90                   	nop
}
801031fd:	c9                   	leave  
801031fe:	c3                   	ret    

801031ff <lapicid>:

int
lapicid(void)
{
801031ff:	f3 0f 1e fb          	endbr32 
80103203:	55                   	push   %ebp
80103204:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103206:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010320b:	85 c0                	test   %eax,%eax
8010320d:	75 07                	jne    80103216 <lapicid+0x17>
    return 0;
8010320f:	b8 00 00 00 00       	mov    $0x0,%eax
80103214:	eb 0d                	jmp    80103223 <lapicid+0x24>
  return lapic[ID] >> 24;
80103216:	a1 1c 57 11 80       	mov    0x8011571c,%eax
8010321b:	83 c0 20             	add    $0x20,%eax
8010321e:	8b 00                	mov    (%eax),%eax
80103220:	c1 e8 18             	shr    $0x18,%eax
}
80103223:	5d                   	pop    %ebp
80103224:	c3                   	ret    

80103225 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103225:	f3 0f 1e fb          	endbr32 
80103229:	55                   	push   %ebp
8010322a:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010322c:	a1 1c 57 11 80       	mov    0x8011571c,%eax
80103231:	85 c0                	test   %eax,%eax
80103233:	74 0c                	je     80103241 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80103235:	6a 00                	push   $0x0
80103237:	6a 2c                	push   $0x2c
80103239:	e8 78 fe ff ff       	call   801030b6 <lapicw>
8010323e:	83 c4 08             	add    $0x8,%esp
}
80103241:	90                   	nop
80103242:	c9                   	leave  
80103243:	c3                   	ret    

80103244 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103244:	f3 0f 1e fb          	endbr32 
80103248:	55                   	push   %ebp
80103249:	89 e5                	mov    %esp,%ebp
}
8010324b:	90                   	nop
8010324c:	5d                   	pop    %ebp
8010324d:	c3                   	ret    

8010324e <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010324e:	f3 0f 1e fb          	endbr32 
80103252:	55                   	push   %ebp
80103253:	89 e5                	mov    %esp,%ebp
80103255:	83 ec 14             	sub    $0x14,%esp
80103258:	8b 45 08             	mov    0x8(%ebp),%eax
8010325b:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010325e:	6a 0f                	push   $0xf
80103260:	6a 70                	push   $0x70
80103262:	e8 2e fe ff ff       	call   80103095 <outb>
80103267:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010326a:	6a 0a                	push   $0xa
8010326c:	6a 71                	push   $0x71
8010326e:	e8 22 fe ff ff       	call   80103095 <outb>
80103273:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103276:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010327d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103280:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103285:	8b 45 0c             	mov    0xc(%ebp),%eax
80103288:	c1 e8 04             	shr    $0x4,%eax
8010328b:	89 c2                	mov    %eax,%edx
8010328d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103290:	83 c0 02             	add    $0x2,%eax
80103293:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103296:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010329a:	c1 e0 18             	shl    $0x18,%eax
8010329d:	50                   	push   %eax
8010329e:	68 c4 00 00 00       	push   $0xc4
801032a3:	e8 0e fe ff ff       	call   801030b6 <lapicw>
801032a8:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801032ab:	68 00 c5 00 00       	push   $0xc500
801032b0:	68 c0 00 00 00       	push   $0xc0
801032b5:	e8 fc fd ff ff       	call   801030b6 <lapicw>
801032ba:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801032bd:	68 c8 00 00 00       	push   $0xc8
801032c2:	e8 7d ff ff ff       	call   80103244 <microdelay>
801032c7:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801032ca:	68 00 85 00 00       	push   $0x8500
801032cf:	68 c0 00 00 00       	push   $0xc0
801032d4:	e8 dd fd ff ff       	call   801030b6 <lapicw>
801032d9:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032dc:	6a 64                	push   $0x64
801032de:	e8 61 ff ff ff       	call   80103244 <microdelay>
801032e3:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032ed:	eb 3d                	jmp    8010332c <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801032ef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032f3:	c1 e0 18             	shl    $0x18,%eax
801032f6:	50                   	push   %eax
801032f7:	68 c4 00 00 00       	push   $0xc4
801032fc:	e8 b5 fd ff ff       	call   801030b6 <lapicw>
80103301:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103304:	8b 45 0c             	mov    0xc(%ebp),%eax
80103307:	c1 e8 0c             	shr    $0xc,%eax
8010330a:	80 cc 06             	or     $0x6,%ah
8010330d:	50                   	push   %eax
8010330e:	68 c0 00 00 00       	push   $0xc0
80103313:	e8 9e fd ff ff       	call   801030b6 <lapicw>
80103318:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010331b:	68 c8 00 00 00       	push   $0xc8
80103320:	e8 1f ff ff ff       	call   80103244 <microdelay>
80103325:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80103328:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010332c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103330:	7e bd                	jle    801032ef <lapicstartap+0xa1>
  }
}
80103332:	90                   	nop
80103333:	90                   	nop
80103334:	c9                   	leave  
80103335:	c3                   	ret    

80103336 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103336:	f3 0f 1e fb          	endbr32 
8010333a:	55                   	push   %ebp
8010333b:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010333d:	8b 45 08             	mov    0x8(%ebp),%eax
80103340:	0f b6 c0             	movzbl %al,%eax
80103343:	50                   	push   %eax
80103344:	6a 70                	push   $0x70
80103346:	e8 4a fd ff ff       	call   80103095 <outb>
8010334b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010334e:	68 c8 00 00 00       	push   $0xc8
80103353:	e8 ec fe ff ff       	call   80103244 <microdelay>
80103358:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010335b:	6a 71                	push   $0x71
8010335d:	e8 16 fd ff ff       	call   80103078 <inb>
80103362:	83 c4 04             	add    $0x4,%esp
80103365:	0f b6 c0             	movzbl %al,%eax
}
80103368:	c9                   	leave  
80103369:	c3                   	ret    

8010336a <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010336a:	f3 0f 1e fb          	endbr32 
8010336e:	55                   	push   %ebp
8010336f:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103371:	6a 00                	push   $0x0
80103373:	e8 be ff ff ff       	call   80103336 <cmos_read>
80103378:	83 c4 04             	add    $0x4,%esp
8010337b:	8b 55 08             	mov    0x8(%ebp),%edx
8010337e:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103380:	6a 02                	push   $0x2
80103382:	e8 af ff ff ff       	call   80103336 <cmos_read>
80103387:	83 c4 04             	add    $0x4,%esp
8010338a:	8b 55 08             	mov    0x8(%ebp),%edx
8010338d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103390:	6a 04                	push   $0x4
80103392:	e8 9f ff ff ff       	call   80103336 <cmos_read>
80103397:	83 c4 04             	add    $0x4,%esp
8010339a:	8b 55 08             	mov    0x8(%ebp),%edx
8010339d:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801033a0:	6a 07                	push   $0x7
801033a2:	e8 8f ff ff ff       	call   80103336 <cmos_read>
801033a7:	83 c4 04             	add    $0x4,%esp
801033aa:	8b 55 08             	mov    0x8(%ebp),%edx
801033ad:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801033b0:	6a 08                	push   $0x8
801033b2:	e8 7f ff ff ff       	call   80103336 <cmos_read>
801033b7:	83 c4 04             	add    $0x4,%esp
801033ba:	8b 55 08             	mov    0x8(%ebp),%edx
801033bd:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801033c0:	6a 09                	push   $0x9
801033c2:	e8 6f ff ff ff       	call   80103336 <cmos_read>
801033c7:	83 c4 04             	add    $0x4,%esp
801033ca:	8b 55 08             	mov    0x8(%ebp),%edx
801033cd:	89 42 14             	mov    %eax,0x14(%edx)
}
801033d0:	90                   	nop
801033d1:	c9                   	leave  
801033d2:	c3                   	ret    

801033d3 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801033d3:	f3 0f 1e fb          	endbr32 
801033d7:	55                   	push   %ebp
801033d8:	89 e5                	mov    %esp,%ebp
801033da:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033dd:	6a 0b                	push   $0xb
801033df:	e8 52 ff ff ff       	call   80103336 <cmos_read>
801033e4:	83 c4 04             	add    $0x4,%esp
801033e7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ed:	83 e0 04             	and    $0x4,%eax
801033f0:	85 c0                	test   %eax,%eax
801033f2:	0f 94 c0             	sete   %al
801033f5:	0f b6 c0             	movzbl %al,%eax
801033f8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033fb:	8d 45 d8             	lea    -0x28(%ebp),%eax
801033fe:	50                   	push   %eax
801033ff:	e8 66 ff ff ff       	call   8010336a <fill_rtcdate>
80103404:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103407:	6a 0a                	push   $0xa
80103409:	e8 28 ff ff ff       	call   80103336 <cmos_read>
8010340e:	83 c4 04             	add    $0x4,%esp
80103411:	25 80 00 00 00       	and    $0x80,%eax
80103416:	85 c0                	test   %eax,%eax
80103418:	75 27                	jne    80103441 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
8010341a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010341d:	50                   	push   %eax
8010341e:	e8 47 ff ff ff       	call   8010336a <fill_rtcdate>
80103423:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103426:	83 ec 04             	sub    $0x4,%esp
80103429:	6a 18                	push   $0x18
8010342b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010342e:	50                   	push   %eax
8010342f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103432:	50                   	push   %eax
80103433:	e8 81 23 00 00       	call   801057b9 <memcmp>
80103438:	83 c4 10             	add    $0x10,%esp
8010343b:	85 c0                	test   %eax,%eax
8010343d:	74 05                	je     80103444 <cmostime+0x71>
8010343f:	eb ba                	jmp    801033fb <cmostime+0x28>
        continue;
80103441:	90                   	nop
    fill_rtcdate(&t1);
80103442:	eb b7                	jmp    801033fb <cmostime+0x28>
      break;
80103444:	90                   	nop
  }

  // convert
  if(bcd) {
80103445:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103449:	0f 84 b4 00 00 00    	je     80103503 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010344f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103452:	c1 e8 04             	shr    $0x4,%eax
80103455:	89 c2                	mov    %eax,%edx
80103457:	89 d0                	mov    %edx,%eax
80103459:	c1 e0 02             	shl    $0x2,%eax
8010345c:	01 d0                	add    %edx,%eax
8010345e:	01 c0                	add    %eax,%eax
80103460:	89 c2                	mov    %eax,%edx
80103462:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103465:	83 e0 0f             	and    $0xf,%eax
80103468:	01 d0                	add    %edx,%eax
8010346a:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010346d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103470:	c1 e8 04             	shr    $0x4,%eax
80103473:	89 c2                	mov    %eax,%edx
80103475:	89 d0                	mov    %edx,%eax
80103477:	c1 e0 02             	shl    $0x2,%eax
8010347a:	01 d0                	add    %edx,%eax
8010347c:	01 c0                	add    %eax,%eax
8010347e:	89 c2                	mov    %eax,%edx
80103480:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103483:	83 e0 0f             	and    $0xf,%eax
80103486:	01 d0                	add    %edx,%eax
80103488:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010348b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010348e:	c1 e8 04             	shr    $0x4,%eax
80103491:	89 c2                	mov    %eax,%edx
80103493:	89 d0                	mov    %edx,%eax
80103495:	c1 e0 02             	shl    $0x2,%eax
80103498:	01 d0                	add    %edx,%eax
8010349a:	01 c0                	add    %eax,%eax
8010349c:	89 c2                	mov    %eax,%edx
8010349e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801034a1:	83 e0 0f             	and    $0xf,%eax
801034a4:	01 d0                	add    %edx,%eax
801034a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801034a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034ac:	c1 e8 04             	shr    $0x4,%eax
801034af:	89 c2                	mov    %eax,%edx
801034b1:	89 d0                	mov    %edx,%eax
801034b3:	c1 e0 02             	shl    $0x2,%eax
801034b6:	01 d0                	add    %edx,%eax
801034b8:	01 c0                	add    %eax,%eax
801034ba:	89 c2                	mov    %eax,%edx
801034bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034bf:	83 e0 0f             	and    $0xf,%eax
801034c2:	01 d0                	add    %edx,%eax
801034c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801034c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034ca:	c1 e8 04             	shr    $0x4,%eax
801034cd:	89 c2                	mov    %eax,%edx
801034cf:	89 d0                	mov    %edx,%eax
801034d1:	c1 e0 02             	shl    $0x2,%eax
801034d4:	01 d0                	add    %edx,%eax
801034d6:	01 c0                	add    %eax,%eax
801034d8:	89 c2                	mov    %eax,%edx
801034da:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034dd:	83 e0 0f             	and    $0xf,%eax
801034e0:	01 d0                	add    %edx,%eax
801034e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801034e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e8:	c1 e8 04             	shr    $0x4,%eax
801034eb:	89 c2                	mov    %eax,%edx
801034ed:	89 d0                	mov    %edx,%eax
801034ef:	c1 e0 02             	shl    $0x2,%eax
801034f2:	01 d0                	add    %edx,%eax
801034f4:	01 c0                	add    %eax,%eax
801034f6:	89 c2                	mov    %eax,%edx
801034f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fb:	83 e0 0f             	and    $0xf,%eax
801034fe:	01 d0                	add    %edx,%eax
80103500:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103503:	8b 45 08             	mov    0x8(%ebp),%eax
80103506:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103509:	89 10                	mov    %edx,(%eax)
8010350b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010350e:	89 50 04             	mov    %edx,0x4(%eax)
80103511:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103514:	89 50 08             	mov    %edx,0x8(%eax)
80103517:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010351a:	89 50 0c             	mov    %edx,0xc(%eax)
8010351d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103520:	89 50 10             	mov    %edx,0x10(%eax)
80103523:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103526:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103529:	8b 45 08             	mov    0x8(%ebp),%eax
8010352c:	8b 40 14             	mov    0x14(%eax),%eax
8010352f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103535:	8b 45 08             	mov    0x8(%ebp),%eax
80103538:	89 50 14             	mov    %edx,0x14(%eax)
}
8010353b:	90                   	nop
8010353c:	c9                   	leave  
8010353d:	c3                   	ret    

8010353e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010353e:	f3 0f 1e fb          	endbr32 
80103542:	55                   	push   %ebp
80103543:	89 e5                	mov    %esp,%ebp
80103545:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103548:	83 ec 08             	sub    $0x8,%esp
8010354b:	68 1c 98 10 80       	push   $0x8010981c
80103550:	68 20 57 11 80       	push   $0x80115720
80103555:	e8 2f 1f 00 00       	call   80105489 <initlock>
8010355a:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010355d:	83 ec 08             	sub    $0x8,%esp
80103560:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103563:	50                   	push   %eax
80103564:	ff 75 08             	pushl  0x8(%ebp)
80103567:	e8 d3 df ff ff       	call   8010153f <readsb>
8010356c:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010356f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103572:	a3 54 57 11 80       	mov    %eax,0x80115754
  log.size = sb.nlog;
80103577:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010357a:	a3 58 57 11 80       	mov    %eax,0x80115758
  log.dev = dev;
8010357f:	8b 45 08             	mov    0x8(%ebp),%eax
80103582:	a3 64 57 11 80       	mov    %eax,0x80115764
  recover_from_log();
80103587:	e8 bf 01 00 00       	call   8010374b <recover_from_log>
}
8010358c:	90                   	nop
8010358d:	c9                   	leave  
8010358e:	c3                   	ret    

8010358f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010358f:	f3 0f 1e fb          	endbr32 
80103593:	55                   	push   %ebp
80103594:	89 e5                	mov    %esp,%ebp
80103596:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103599:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035a0:	e9 95 00 00 00       	jmp    8010363a <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801035a5:	8b 15 54 57 11 80    	mov    0x80115754,%edx
801035ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ae:	01 d0                	add    %edx,%eax
801035b0:	83 c0 01             	add    $0x1,%eax
801035b3:	89 c2                	mov    %eax,%edx
801035b5:	a1 64 57 11 80       	mov    0x80115764,%eax
801035ba:	83 ec 08             	sub    $0x8,%esp
801035bd:	52                   	push   %edx
801035be:	50                   	push   %eax
801035bf:	e8 13 cc ff ff       	call   801001d7 <bread>
801035c4:	83 c4 10             	add    $0x10,%esp
801035c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801035ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035cd:	83 c0 10             	add    $0x10,%eax
801035d0:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
801035d7:	89 c2                	mov    %eax,%edx
801035d9:	a1 64 57 11 80       	mov    0x80115764,%eax
801035de:	83 ec 08             	sub    $0x8,%esp
801035e1:	52                   	push   %edx
801035e2:	50                   	push   %eax
801035e3:	e8 ef cb ff ff       	call   801001d7 <bread>
801035e8:	83 c4 10             	add    $0x10,%esp
801035eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035f1:	8d 50 5c             	lea    0x5c(%eax),%edx
801035f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035f7:	83 c0 5c             	add    $0x5c,%eax
801035fa:	83 ec 04             	sub    $0x4,%esp
801035fd:	68 00 02 00 00       	push   $0x200
80103602:	52                   	push   %edx
80103603:	50                   	push   %eax
80103604:	e8 0c 22 00 00       	call   80105815 <memmove>
80103609:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010360c:	83 ec 0c             	sub    $0xc,%esp
8010360f:	ff 75 ec             	pushl  -0x14(%ebp)
80103612:	e8 fd cb ff ff       	call   80100214 <bwrite>
80103617:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	ff 75 f0             	pushl  -0x10(%ebp)
80103620:	e8 3c cc ff ff       	call   80100261 <brelse>
80103625:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103628:	83 ec 0c             	sub    $0xc,%esp
8010362b:	ff 75 ec             	pushl  -0x14(%ebp)
8010362e:	e8 2e cc ff ff       	call   80100261 <brelse>
80103633:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103636:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010363a:	a1 68 57 11 80       	mov    0x80115768,%eax
8010363f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103642:	0f 8c 5d ff ff ff    	jl     801035a5 <install_trans+0x16>
  }
}
80103648:	90                   	nop
80103649:	90                   	nop
8010364a:	c9                   	leave  
8010364b:	c3                   	ret    

8010364c <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010364c:	f3 0f 1e fb          	endbr32 
80103650:	55                   	push   %ebp
80103651:	89 e5                	mov    %esp,%ebp
80103653:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103656:	a1 54 57 11 80       	mov    0x80115754,%eax
8010365b:	89 c2                	mov    %eax,%edx
8010365d:	a1 64 57 11 80       	mov    0x80115764,%eax
80103662:	83 ec 08             	sub    $0x8,%esp
80103665:	52                   	push   %edx
80103666:	50                   	push   %eax
80103667:	e8 6b cb ff ff       	call   801001d7 <bread>
8010366c:	83 c4 10             	add    $0x10,%esp
8010366f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103672:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103675:	83 c0 5c             	add    $0x5c,%eax
80103678:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010367b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010367e:	8b 00                	mov    (%eax),%eax
80103680:	a3 68 57 11 80       	mov    %eax,0x80115768
  for (i = 0; i < log.lh.n; i++) {
80103685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368c:	eb 1b                	jmp    801036a9 <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
8010368e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103691:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103694:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010369b:	83 c2 10             	add    $0x10,%edx
8010369e:	89 04 95 2c 57 11 80 	mov    %eax,-0x7feea8d4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801036a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036a9:	a1 68 57 11 80       	mov    0x80115768,%eax
801036ae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801036b1:	7c db                	jl     8010368e <read_head+0x42>
  }
  brelse(buf);
801036b3:	83 ec 0c             	sub    $0xc,%esp
801036b6:	ff 75 f0             	pushl  -0x10(%ebp)
801036b9:	e8 a3 cb ff ff       	call   80100261 <brelse>
801036be:	83 c4 10             	add    $0x10,%esp
}
801036c1:	90                   	nop
801036c2:	c9                   	leave  
801036c3:	c3                   	ret    

801036c4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801036c4:	f3 0f 1e fb          	endbr32 
801036c8:	55                   	push   %ebp
801036c9:	89 e5                	mov    %esp,%ebp
801036cb:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801036ce:	a1 54 57 11 80       	mov    0x80115754,%eax
801036d3:	89 c2                	mov    %eax,%edx
801036d5:	a1 64 57 11 80       	mov    0x80115764,%eax
801036da:	83 ec 08             	sub    $0x8,%esp
801036dd:	52                   	push   %edx
801036de:	50                   	push   %eax
801036df:	e8 f3 ca ff ff       	call   801001d7 <bread>
801036e4:	83 c4 10             	add    $0x10,%esp
801036e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801036ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ed:	83 c0 5c             	add    $0x5c,%eax
801036f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801036f3:	8b 15 68 57 11 80    	mov    0x80115768,%edx
801036f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801036fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103705:	eb 1b                	jmp    80103722 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010370a:	83 c0 10             	add    $0x10,%eax
8010370d:	8b 0c 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%ecx
80103714:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103717:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010371a:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010371e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103722:	a1 68 57 11 80       	mov    0x80115768,%eax
80103727:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010372a:	7c db                	jl     80103707 <write_head+0x43>
  }
  bwrite(buf);
8010372c:	83 ec 0c             	sub    $0xc,%esp
8010372f:	ff 75 f0             	pushl  -0x10(%ebp)
80103732:	e8 dd ca ff ff       	call   80100214 <bwrite>
80103737:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010373a:	83 ec 0c             	sub    $0xc,%esp
8010373d:	ff 75 f0             	pushl  -0x10(%ebp)
80103740:	e8 1c cb ff ff       	call   80100261 <brelse>
80103745:	83 c4 10             	add    $0x10,%esp
}
80103748:	90                   	nop
80103749:	c9                   	leave  
8010374a:	c3                   	ret    

8010374b <recover_from_log>:

static void
recover_from_log(void)
{
8010374b:	f3 0f 1e fb          	endbr32 
8010374f:	55                   	push   %ebp
80103750:	89 e5                	mov    %esp,%ebp
80103752:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103755:	e8 f2 fe ff ff       	call   8010364c <read_head>
  install_trans(); // if committed, copy from log to disk
8010375a:	e8 30 fe ff ff       	call   8010358f <install_trans>
  log.lh.n = 0;
8010375f:	c7 05 68 57 11 80 00 	movl   $0x0,0x80115768
80103766:	00 00 00 
  write_head(); // clear the log
80103769:	e8 56 ff ff ff       	call   801036c4 <write_head>
}
8010376e:	90                   	nop
8010376f:	c9                   	leave  
80103770:	c3                   	ret    

80103771 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103771:	f3 0f 1e fb          	endbr32 
80103775:	55                   	push   %ebp
80103776:	89 e5                	mov    %esp,%ebp
80103778:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010377b:	83 ec 0c             	sub    $0xc,%esp
8010377e:	68 20 57 11 80       	push   $0x80115720
80103783:	e8 27 1d 00 00       	call   801054af <acquire>
80103788:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010378b:	a1 60 57 11 80       	mov    0x80115760,%eax
80103790:	85 c0                	test   %eax,%eax
80103792:	74 17                	je     801037ab <begin_op+0x3a>
      sleep(&log, &log.lock);
80103794:	83 ec 08             	sub    $0x8,%esp
80103797:	68 20 57 11 80       	push   $0x80115720
8010379c:	68 20 57 11 80       	push   $0x80115720
801037a1:	e8 97 18 00 00       	call   8010503d <sleep>
801037a6:	83 c4 10             	add    $0x10,%esp
801037a9:	eb e0                	jmp    8010378b <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801037ab:	8b 0d 68 57 11 80    	mov    0x80115768,%ecx
801037b1:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801037b6:	8d 50 01             	lea    0x1(%eax),%edx
801037b9:	89 d0                	mov    %edx,%eax
801037bb:	c1 e0 02             	shl    $0x2,%eax
801037be:	01 d0                	add    %edx,%eax
801037c0:	01 c0                	add    %eax,%eax
801037c2:	01 c8                	add    %ecx,%eax
801037c4:	83 f8 1e             	cmp    $0x1e,%eax
801037c7:	7e 17                	jle    801037e0 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801037c9:	83 ec 08             	sub    $0x8,%esp
801037cc:	68 20 57 11 80       	push   $0x80115720
801037d1:	68 20 57 11 80       	push   $0x80115720
801037d6:	e8 62 18 00 00       	call   8010503d <sleep>
801037db:	83 c4 10             	add    $0x10,%esp
801037de:	eb ab                	jmp    8010378b <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801037e0:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801037e5:	83 c0 01             	add    $0x1,%eax
801037e8:	a3 5c 57 11 80       	mov    %eax,0x8011575c
      release(&log.lock);
801037ed:	83 ec 0c             	sub    $0xc,%esp
801037f0:	68 20 57 11 80       	push   $0x80115720
801037f5:	e8 27 1d 00 00       	call   80105521 <release>
801037fa:	83 c4 10             	add    $0x10,%esp
      break;
801037fd:	90                   	nop
    }
  }
}
801037fe:	90                   	nop
801037ff:	c9                   	leave  
80103800:	c3                   	ret    

80103801 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103801:	f3 0f 1e fb          	endbr32 
80103805:	55                   	push   %ebp
80103806:	89 e5                	mov    %esp,%ebp
80103808:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010380b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103812:	83 ec 0c             	sub    $0xc,%esp
80103815:	68 20 57 11 80       	push   $0x80115720
8010381a:	e8 90 1c 00 00       	call   801054af <acquire>
8010381f:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103822:	a1 5c 57 11 80       	mov    0x8011575c,%eax
80103827:	83 e8 01             	sub    $0x1,%eax
8010382a:	a3 5c 57 11 80       	mov    %eax,0x8011575c
  if(log.committing)
8010382f:	a1 60 57 11 80       	mov    0x80115760,%eax
80103834:	85 c0                	test   %eax,%eax
80103836:	74 0d                	je     80103845 <end_op+0x44>
    panic("log.committing");
80103838:	83 ec 0c             	sub    $0xc,%esp
8010383b:	68 20 98 10 80       	push   $0x80109820
80103840:	e8 c3 cd ff ff       	call   80100608 <panic>
  if(log.outstanding == 0){
80103845:	a1 5c 57 11 80       	mov    0x8011575c,%eax
8010384a:	85 c0                	test   %eax,%eax
8010384c:	75 13                	jne    80103861 <end_op+0x60>
    do_commit = 1;
8010384e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103855:	c7 05 60 57 11 80 01 	movl   $0x1,0x80115760
8010385c:	00 00 00 
8010385f:	eb 10                	jmp    80103871 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103861:	83 ec 0c             	sub    $0xc,%esp
80103864:	68 20 57 11 80       	push   $0x80115720
80103869:	e8 c1 18 00 00       	call   8010512f <wakeup>
8010386e:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103871:	83 ec 0c             	sub    $0xc,%esp
80103874:	68 20 57 11 80       	push   $0x80115720
80103879:	e8 a3 1c 00 00       	call   80105521 <release>
8010387e:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103881:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103885:	74 3f                	je     801038c6 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103887:	e8 fa 00 00 00       	call   80103986 <commit>
    acquire(&log.lock);
8010388c:	83 ec 0c             	sub    $0xc,%esp
8010388f:	68 20 57 11 80       	push   $0x80115720
80103894:	e8 16 1c 00 00       	call   801054af <acquire>
80103899:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010389c:	c7 05 60 57 11 80 00 	movl   $0x0,0x80115760
801038a3:	00 00 00 
    wakeup(&log);
801038a6:	83 ec 0c             	sub    $0xc,%esp
801038a9:	68 20 57 11 80       	push   $0x80115720
801038ae:	e8 7c 18 00 00       	call   8010512f <wakeup>
801038b3:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801038b6:	83 ec 0c             	sub    $0xc,%esp
801038b9:	68 20 57 11 80       	push   $0x80115720
801038be:	e8 5e 1c 00 00       	call   80105521 <release>
801038c3:	83 c4 10             	add    $0x10,%esp
  }
}
801038c6:	90                   	nop
801038c7:	c9                   	leave  
801038c8:	c3                   	ret    

801038c9 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801038c9:	f3 0f 1e fb          	endbr32 
801038cd:	55                   	push   %ebp
801038ce:	89 e5                	mov    %esp,%ebp
801038d0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038da:	e9 95 00 00 00       	jmp    80103974 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801038df:	8b 15 54 57 11 80    	mov    0x80115754,%edx
801038e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038e8:	01 d0                	add    %edx,%eax
801038ea:	83 c0 01             	add    $0x1,%eax
801038ed:	89 c2                	mov    %eax,%edx
801038ef:	a1 64 57 11 80       	mov    0x80115764,%eax
801038f4:	83 ec 08             	sub    $0x8,%esp
801038f7:	52                   	push   %edx
801038f8:	50                   	push   %eax
801038f9:	e8 d9 c8 ff ff       	call   801001d7 <bread>
801038fe:	83 c4 10             	add    $0x10,%esp
80103901:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103907:	83 c0 10             	add    $0x10,%eax
8010390a:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
80103911:	89 c2                	mov    %eax,%edx
80103913:	a1 64 57 11 80       	mov    0x80115764,%eax
80103918:	83 ec 08             	sub    $0x8,%esp
8010391b:	52                   	push   %edx
8010391c:	50                   	push   %eax
8010391d:	e8 b5 c8 ff ff       	call   801001d7 <bread>
80103922:	83 c4 10             	add    $0x10,%esp
80103925:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103928:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010392b:	8d 50 5c             	lea    0x5c(%eax),%edx
8010392e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103931:	83 c0 5c             	add    $0x5c,%eax
80103934:	83 ec 04             	sub    $0x4,%esp
80103937:	68 00 02 00 00       	push   $0x200
8010393c:	52                   	push   %edx
8010393d:	50                   	push   %eax
8010393e:	e8 d2 1e 00 00       	call   80105815 <memmove>
80103943:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103946:	83 ec 0c             	sub    $0xc,%esp
80103949:	ff 75 f0             	pushl  -0x10(%ebp)
8010394c:	e8 c3 c8 ff ff       	call   80100214 <bwrite>
80103951:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103954:	83 ec 0c             	sub    $0xc,%esp
80103957:	ff 75 ec             	pushl  -0x14(%ebp)
8010395a:	e8 02 c9 ff ff       	call   80100261 <brelse>
8010395f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103962:	83 ec 0c             	sub    $0xc,%esp
80103965:	ff 75 f0             	pushl  -0x10(%ebp)
80103968:	e8 f4 c8 ff ff       	call   80100261 <brelse>
8010396d:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103970:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103974:	a1 68 57 11 80       	mov    0x80115768,%eax
80103979:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010397c:	0f 8c 5d ff ff ff    	jl     801038df <write_log+0x16>
  }
}
80103982:	90                   	nop
80103983:	90                   	nop
80103984:	c9                   	leave  
80103985:	c3                   	ret    

80103986 <commit>:

static void
commit()
{
80103986:	f3 0f 1e fb          	endbr32 
8010398a:	55                   	push   %ebp
8010398b:	89 e5                	mov    %esp,%ebp
8010398d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103990:	a1 68 57 11 80       	mov    0x80115768,%eax
80103995:	85 c0                	test   %eax,%eax
80103997:	7e 1e                	jle    801039b7 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
80103999:	e8 2b ff ff ff       	call   801038c9 <write_log>
    write_head();    // Write header to disk -- the real commit
8010399e:	e8 21 fd ff ff       	call   801036c4 <write_head>
    install_trans(); // Now install writes to home locations
801039a3:	e8 e7 fb ff ff       	call   8010358f <install_trans>
    log.lh.n = 0;
801039a8:	c7 05 68 57 11 80 00 	movl   $0x0,0x80115768
801039af:	00 00 00 
    write_head();    // Erase the transaction from the log
801039b2:	e8 0d fd ff ff       	call   801036c4 <write_head>
  }
}
801039b7:	90                   	nop
801039b8:	c9                   	leave  
801039b9:	c3                   	ret    

801039ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801039ba:	f3 0f 1e fb          	endbr32 
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801039c4:	a1 68 57 11 80       	mov    0x80115768,%eax
801039c9:	83 f8 1d             	cmp    $0x1d,%eax
801039cc:	7f 12                	jg     801039e0 <log_write+0x26>
801039ce:	a1 68 57 11 80       	mov    0x80115768,%eax
801039d3:	8b 15 58 57 11 80    	mov    0x80115758,%edx
801039d9:	83 ea 01             	sub    $0x1,%edx
801039dc:	39 d0                	cmp    %edx,%eax
801039de:	7c 0d                	jl     801039ed <log_write+0x33>
    panic("too big a transaction");
801039e0:	83 ec 0c             	sub    $0xc,%esp
801039e3:	68 2f 98 10 80       	push   $0x8010982f
801039e8:	e8 1b cc ff ff       	call   80100608 <panic>
  if (log.outstanding < 1)
801039ed:	a1 5c 57 11 80       	mov    0x8011575c,%eax
801039f2:	85 c0                	test   %eax,%eax
801039f4:	7f 0d                	jg     80103a03 <log_write+0x49>
    panic("log_write outside of trans");
801039f6:	83 ec 0c             	sub    $0xc,%esp
801039f9:	68 45 98 10 80       	push   $0x80109845
801039fe:	e8 05 cc ff ff       	call   80100608 <panic>

  acquire(&log.lock);
80103a03:	83 ec 0c             	sub    $0xc,%esp
80103a06:	68 20 57 11 80       	push   $0x80115720
80103a0b:	e8 9f 1a 00 00       	call   801054af <acquire>
80103a10:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a1a:	eb 1d                	jmp    80103a39 <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a1f:	83 c0 10             	add    $0x10,%eax
80103a22:	8b 04 85 2c 57 11 80 	mov    -0x7feea8d4(,%eax,4),%eax
80103a29:	89 c2                	mov    %eax,%edx
80103a2b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2e:	8b 40 08             	mov    0x8(%eax),%eax
80103a31:	39 c2                	cmp    %eax,%edx
80103a33:	74 10                	je     80103a45 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103a35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a39:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a3e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a41:	7c d9                	jl     80103a1c <log_write+0x62>
80103a43:	eb 01                	jmp    80103a46 <log_write+0x8c>
      break;
80103a45:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103a46:	8b 45 08             	mov    0x8(%ebp),%eax
80103a49:	8b 40 08             	mov    0x8(%eax),%eax
80103a4c:	89 c2                	mov    %eax,%edx
80103a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a51:	83 c0 10             	add    $0x10,%eax
80103a54:	89 14 85 2c 57 11 80 	mov    %edx,-0x7feea8d4(,%eax,4)
  if (i == log.lh.n)
80103a5b:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a60:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a63:	75 0d                	jne    80103a72 <log_write+0xb8>
    log.lh.n++;
80103a65:	a1 68 57 11 80       	mov    0x80115768,%eax
80103a6a:	83 c0 01             	add    $0x1,%eax
80103a6d:	a3 68 57 11 80       	mov    %eax,0x80115768
  b->flags |= B_DIRTY; // prevent eviction
80103a72:	8b 45 08             	mov    0x8(%ebp),%eax
80103a75:	8b 00                	mov    (%eax),%eax
80103a77:	83 c8 04             	or     $0x4,%eax
80103a7a:	89 c2                	mov    %eax,%edx
80103a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103a81:	83 ec 0c             	sub    $0xc,%esp
80103a84:	68 20 57 11 80       	push   $0x80115720
80103a89:	e8 93 1a 00 00       	call   80105521 <release>
80103a8e:	83 c4 10             	add    $0x10,%esp
}
80103a91:	90                   	nop
80103a92:	c9                   	leave  
80103a93:	c3                   	ret    

80103a94 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103a94:	55                   	push   %ebp
80103a95:	89 e5                	mov    %esp,%ebp
80103a97:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103a9a:	8b 55 08             	mov    0x8(%ebp),%edx
80103a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103aa3:	f0 87 02             	lock xchg %eax,(%edx)
80103aa6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103aa9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103aac:	c9                   	leave  
80103aad:	c3                   	ret    

80103aae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103aae:	f3 0f 1e fb          	endbr32 
80103ab2:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103ab6:	83 e4 f0             	and    $0xfffffff0,%esp
80103ab9:	ff 71 fc             	pushl  -0x4(%ecx)
80103abc:	55                   	push   %ebp
80103abd:	89 e5                	mov    %esp,%ebp
80103abf:	51                   	push   %ecx
80103ac0:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103ac3:	83 ec 08             	sub    $0x8,%esp
80103ac6:	68 00 00 40 80       	push   $0x80400000
80103acb:	68 48 8f 11 80       	push   $0x80118f48
80103ad0:	e8 52 f2 ff ff       	call   80102d27 <kinit1>
80103ad5:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103ad8:	e8 64 48 00 00       	call   80108341 <kvmalloc>
  mpinit();        // detect other processors
80103add:	e8 d9 03 00 00       	call   80103ebb <mpinit>
  lapicinit();     // interrupt controller
80103ae2:	e8 f5 f5 ff ff       	call   801030dc <lapicinit>
  seginit();       // segment descriptors
80103ae7:	e8 0d 43 00 00       	call   80107df9 <seginit>
  picinit();       // disable pic
80103aec:	e8 35 05 00 00       	call   80104026 <picinit>
  ioapicinit();    // another interrupt controller
80103af1:	e8 44 f1 ff ff       	call   80102c3a <ioapicinit>
  consoleinit();   // console hardware
80103af6:	e8 e6 d0 ff ff       	call   80100be1 <consoleinit>
  uartinit();      // serial port
80103afb:	e8 82 36 00 00       	call   80107182 <uartinit>
  pinit();         // process table
80103b00:	e8 6e 09 00 00       	call   80104473 <pinit>
  tvinit();        // trap vectors
80103b05:	e8 00 32 00 00       	call   80106d0a <tvinit>
  binit();         // buffer cache
80103b0a:	e8 25 c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b0f:	e8 00 d6 ff ff       	call   80101114 <fileinit>
  ideinit();       // disk 
80103b14:	e8 e0 ec ff ff       	call   801027f9 <ideinit>
  startothers();   // start other processors
80103b19:	e8 88 00 00 00       	call   80103ba6 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103b1e:	83 ec 08             	sub    $0x8,%esp
80103b21:	68 00 00 00 8e       	push   $0x8e000000
80103b26:	68 00 00 40 80       	push   $0x80400000
80103b2b:	e8 34 f2 ff ff       	call   80102d64 <kinit2>
80103b30:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103b33:	e8 75 0b 00 00       	call   801046ad <userinit>
  mpmain();        // finish this processor's setup
80103b38:	e8 1e 00 00 00       	call   80103b5b <mpmain>

80103b3d <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b3d:	f3 0f 1e fb          	endbr32 
80103b41:	55                   	push   %ebp
80103b42:	89 e5                	mov    %esp,%ebp
80103b44:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103b47:	e8 11 48 00 00       	call   8010835d <switchkvm>
  seginit();
80103b4c:	e8 a8 42 00 00       	call   80107df9 <seginit>
  lapicinit();
80103b51:	e8 86 f5 ff ff       	call   801030dc <lapicinit>
  mpmain();
80103b56:	e8 00 00 00 00       	call   80103b5b <mpmain>

80103b5b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103b5b:	f3 0f 1e fb          	endbr32 
80103b5f:	55                   	push   %ebp
80103b60:	89 e5                	mov    %esp,%ebp
80103b62:	53                   	push   %ebx
80103b63:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103b66:	e8 2a 09 00 00       	call   80104495 <cpuid>
80103b6b:	89 c3                	mov    %eax,%ebx
80103b6d:	e8 23 09 00 00       	call   80104495 <cpuid>
80103b72:	83 ec 04             	sub    $0x4,%esp
80103b75:	53                   	push   %ebx
80103b76:	50                   	push   %eax
80103b77:	68 60 98 10 80       	push   $0x80109860
80103b7c:	e8 97 c8 ff ff       	call   80100418 <cprintf>
80103b81:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103b84:	e8 fb 32 00 00       	call   80106e84 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103b89:	e8 26 09 00 00       	call   801044b4 <mycpu>
80103b8e:	05 a0 00 00 00       	add    $0xa0,%eax
80103b93:	83 ec 08             	sub    $0x8,%esp
80103b96:	6a 01                	push   $0x1
80103b98:	50                   	push   %eax
80103b99:	e8 f6 fe ff ff       	call   80103a94 <xchg>
80103b9e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103ba1:	e8 93 12 00 00       	call   80104e39 <scheduler>

80103ba6 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103ba6:	f3 0f 1e fb          	endbr32 
80103baa:	55                   	push   %ebp
80103bab:	89 e5                	mov    %esp,%ebp
80103bad:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103bb0:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103bb7:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103bbc:	83 ec 04             	sub    $0x4,%esp
80103bbf:	50                   	push   %eax
80103bc0:	68 0c d5 10 80       	push   $0x8010d50c
80103bc5:	ff 75 f0             	pushl  -0x10(%ebp)
80103bc8:	e8 48 1c 00 00       	call   80105815 <memmove>
80103bcd:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103bd0:	c7 45 f4 20 58 11 80 	movl   $0x80115820,-0xc(%ebp)
80103bd7:	eb 79                	jmp    80103c52 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103bd9:	e8 d6 08 00 00       	call   801044b4 <mycpu>
80103bde:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103be1:	74 67                	je     80103c4a <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103be3:	e8 84 f2 ff ff       	call   80102e6c <kalloc>
80103be8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bee:	83 e8 04             	sub    $0x4,%eax
80103bf1:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103bf4:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103bfa:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bff:	83 e8 08             	sub    $0x8,%eax
80103c02:	c7 00 3d 3b 10 80    	movl   $0x80103b3d,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103c08:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103c0d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c16:	83 e8 0c             	sub    $0xc,%eax
80103c19:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c27:	0f b6 00             	movzbl (%eax),%eax
80103c2a:	0f b6 c0             	movzbl %al,%eax
80103c2d:	83 ec 08             	sub    $0x8,%esp
80103c30:	52                   	push   %edx
80103c31:	50                   	push   %eax
80103c32:	e8 17 f6 ff ff       	call   8010324e <lapicstartap>
80103c37:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c3a:	90                   	nop
80103c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103c44:	85 c0                	test   %eax,%eax
80103c46:	74 f3                	je     80103c3b <startothers+0x95>
80103c48:	eb 01                	jmp    80103c4b <startothers+0xa5>
      continue;
80103c4a:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103c4b:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103c52:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103c57:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103c5d:	05 20 58 11 80       	add    $0x80115820,%eax
80103c62:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103c65:	0f 82 6e ff ff ff    	jb     80103bd9 <startothers+0x33>
      ;
  }
}
80103c6b:	90                   	nop
80103c6c:	90                   	nop
80103c6d:	c9                   	leave  
80103c6e:	c3                   	ret    

80103c6f <inb>:
{
80103c6f:	55                   	push   %ebp
80103c70:	89 e5                	mov    %esp,%ebp
80103c72:	83 ec 14             	sub    $0x14,%esp
80103c75:	8b 45 08             	mov    0x8(%ebp),%eax
80103c78:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103c7c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103c80:	89 c2                	mov    %eax,%edx
80103c82:	ec                   	in     (%dx),%al
80103c83:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103c86:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103c8a:	c9                   	leave  
80103c8b:	c3                   	ret    

80103c8c <outb>:
{
80103c8c:	55                   	push   %ebp
80103c8d:	89 e5                	mov    %esp,%ebp
80103c8f:	83 ec 08             	sub    $0x8,%esp
80103c92:	8b 45 08             	mov    0x8(%ebp),%eax
80103c95:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c98:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103c9c:	89 d0                	mov    %edx,%eax
80103c9e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ca1:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ca5:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ca9:	ee                   	out    %al,(%dx)
}
80103caa:	90                   	nop
80103cab:	c9                   	leave  
80103cac:	c3                   	ret    

80103cad <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103cad:	f3 0f 1e fb          	endbr32 
80103cb1:	55                   	push   %ebp
80103cb2:	89 e5                	mov    %esp,%ebp
80103cb4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103cb7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103cbe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103cc5:	eb 15                	jmp    80103cdc <sum+0x2f>
    sum += addr[i];
80103cc7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103cca:	8b 45 08             	mov    0x8(%ebp),%eax
80103ccd:	01 d0                	add    %edx,%eax
80103ccf:	0f b6 00             	movzbl (%eax),%eax
80103cd2:	0f b6 c0             	movzbl %al,%eax
80103cd5:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103cd8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103cdc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103cdf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103ce2:	7c e3                	jl     80103cc7 <sum+0x1a>
  return sum;
80103ce4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103ce7:	c9                   	leave  
80103ce8:	c3                   	ret    

80103ce9 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103ce9:	f3 0f 1e fb          	endbr32 
80103ced:	55                   	push   %ebp
80103cee:	89 e5                	mov    %esp,%ebp
80103cf0:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf6:	05 00 00 00 80       	add    $0x80000000,%eax
80103cfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d04:	01 d0                	add    %edx,%eax
80103d06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d0f:	eb 36                	jmp    80103d47 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103d11:	83 ec 04             	sub    $0x4,%esp
80103d14:	6a 04                	push   $0x4
80103d16:	68 74 98 10 80       	push   $0x80109874
80103d1b:	ff 75 f4             	pushl  -0xc(%ebp)
80103d1e:	e8 96 1a 00 00       	call   801057b9 <memcmp>
80103d23:	83 c4 10             	add    $0x10,%esp
80103d26:	85 c0                	test   %eax,%eax
80103d28:	75 19                	jne    80103d43 <mpsearch1+0x5a>
80103d2a:	83 ec 08             	sub    $0x8,%esp
80103d2d:	6a 10                	push   $0x10
80103d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80103d32:	e8 76 ff ff ff       	call   80103cad <sum>
80103d37:	83 c4 10             	add    $0x10,%esp
80103d3a:	84 c0                	test   %al,%al
80103d3c:	75 05                	jne    80103d43 <mpsearch1+0x5a>
      return (struct mp*)p;
80103d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d41:	eb 11                	jmp    80103d54 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103d43:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d4d:	72 c2                	jb     80103d11 <mpsearch1+0x28>
  return 0;
80103d4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d54:	c9                   	leave  
80103d55:	c3                   	ret    

80103d56 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103d56:	f3 0f 1e fb          	endbr32 
80103d5a:	55                   	push   %ebp
80103d5b:	89 e5                	mov    %esp,%ebp
80103d5d:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103d60:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d6a:	83 c0 0f             	add    $0xf,%eax
80103d6d:	0f b6 00             	movzbl (%eax),%eax
80103d70:	0f b6 c0             	movzbl %al,%eax
80103d73:	c1 e0 08             	shl    $0x8,%eax
80103d76:	89 c2                	mov    %eax,%edx
80103d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d7b:	83 c0 0e             	add    $0xe,%eax
80103d7e:	0f b6 00             	movzbl (%eax),%eax
80103d81:	0f b6 c0             	movzbl %al,%eax
80103d84:	09 d0                	or     %edx,%eax
80103d86:	c1 e0 04             	shl    $0x4,%eax
80103d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d90:	74 21                	je     80103db3 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103d92:	83 ec 08             	sub    $0x8,%esp
80103d95:	68 00 04 00 00       	push   $0x400
80103d9a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d9d:	e8 47 ff ff ff       	call   80103ce9 <mpsearch1>
80103da2:	83 c4 10             	add    $0x10,%esp
80103da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103da8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dac:	74 51                	je     80103dff <mpsearch+0xa9>
      return mp;
80103dae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103db1:	eb 61                	jmp    80103e14 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103db6:	83 c0 14             	add    $0x14,%eax
80103db9:	0f b6 00             	movzbl (%eax),%eax
80103dbc:	0f b6 c0             	movzbl %al,%eax
80103dbf:	c1 e0 08             	shl    $0x8,%eax
80103dc2:	89 c2                	mov    %eax,%edx
80103dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc7:	83 c0 13             	add    $0x13,%eax
80103dca:	0f b6 00             	movzbl (%eax),%eax
80103dcd:	0f b6 c0             	movzbl %al,%eax
80103dd0:	09 d0                	or     %edx,%eax
80103dd2:	c1 e0 0a             	shl    $0xa,%eax
80103dd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103dd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ddb:	2d 00 04 00 00       	sub    $0x400,%eax
80103de0:	83 ec 08             	sub    $0x8,%esp
80103de3:	68 00 04 00 00       	push   $0x400
80103de8:	50                   	push   %eax
80103de9:	e8 fb fe ff ff       	call   80103ce9 <mpsearch1>
80103dee:	83 c4 10             	add    $0x10,%esp
80103df1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103df4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103df8:	74 05                	je     80103dff <mpsearch+0xa9>
      return mp;
80103dfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dfd:	eb 15                	jmp    80103e14 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103dff:	83 ec 08             	sub    $0x8,%esp
80103e02:	68 00 00 01 00       	push   $0x10000
80103e07:	68 00 00 0f 00       	push   $0xf0000
80103e0c:	e8 d8 fe ff ff       	call   80103ce9 <mpsearch1>
80103e11:	83 c4 10             	add    $0x10,%esp
}
80103e14:	c9                   	leave  
80103e15:	c3                   	ret    

80103e16 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103e16:	f3 0f 1e fb          	endbr32 
80103e1a:	55                   	push   %ebp
80103e1b:	89 e5                	mov    %esp,%ebp
80103e1d:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103e20:	e8 31 ff ff ff       	call   80103d56 <mpsearch>
80103e25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e2c:	74 0a                	je     80103e38 <mpconfig+0x22>
80103e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e31:	8b 40 04             	mov    0x4(%eax),%eax
80103e34:	85 c0                	test   %eax,%eax
80103e36:	75 07                	jne    80103e3f <mpconfig+0x29>
    return 0;
80103e38:	b8 00 00 00 00       	mov    $0x0,%eax
80103e3d:	eb 7a                	jmp    80103eb9 <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e42:	8b 40 04             	mov    0x4(%eax),%eax
80103e45:	05 00 00 00 80       	add    $0x80000000,%eax
80103e4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e4d:	83 ec 04             	sub    $0x4,%esp
80103e50:	6a 04                	push   $0x4
80103e52:	68 79 98 10 80       	push   $0x80109879
80103e57:	ff 75 f0             	pushl  -0x10(%ebp)
80103e5a:	e8 5a 19 00 00       	call   801057b9 <memcmp>
80103e5f:	83 c4 10             	add    $0x10,%esp
80103e62:	85 c0                	test   %eax,%eax
80103e64:	74 07                	je     80103e6d <mpconfig+0x57>
    return 0;
80103e66:	b8 00 00 00 00       	mov    $0x0,%eax
80103e6b:	eb 4c                	jmp    80103eb9 <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e70:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e74:	3c 01                	cmp    $0x1,%al
80103e76:	74 12                	je     80103e8a <mpconfig+0x74>
80103e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e7b:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103e7f:	3c 04                	cmp    $0x4,%al
80103e81:	74 07                	je     80103e8a <mpconfig+0x74>
    return 0;
80103e83:	b8 00 00 00 00       	mov    $0x0,%eax
80103e88:	eb 2f                	jmp    80103eb9 <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e8d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e91:	0f b7 c0             	movzwl %ax,%eax
80103e94:	83 ec 08             	sub    $0x8,%esp
80103e97:	50                   	push   %eax
80103e98:	ff 75 f0             	pushl  -0x10(%ebp)
80103e9b:	e8 0d fe ff ff       	call   80103cad <sum>
80103ea0:	83 c4 10             	add    $0x10,%esp
80103ea3:	84 c0                	test   %al,%al
80103ea5:	74 07                	je     80103eae <mpconfig+0x98>
    return 0;
80103ea7:	b8 00 00 00 00       	mov    $0x0,%eax
80103eac:	eb 0b                	jmp    80103eb9 <mpconfig+0xa3>
  *pmp = mp;
80103eae:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103eb4:	89 10                	mov    %edx,(%eax)
  return conf;
80103eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103eb9:	c9                   	leave  
80103eba:	c3                   	ret    

80103ebb <mpinit>:

void
mpinit(void)
{
80103ebb:	f3 0f 1e fb          	endbr32 
80103ebf:	55                   	push   %ebp
80103ec0:	89 e5                	mov    %esp,%ebp
80103ec2:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103ec5:	83 ec 0c             	sub    $0xc,%esp
80103ec8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103ecb:	50                   	push   %eax
80103ecc:	e8 45 ff ff ff       	call   80103e16 <mpconfig>
80103ed1:	83 c4 10             	add    $0x10,%esp
80103ed4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ed7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103edb:	75 0d                	jne    80103eea <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103edd:	83 ec 0c             	sub    $0xc,%esp
80103ee0:	68 7e 98 10 80       	push   $0x8010987e
80103ee5:	e8 1e c7 ff ff       	call   80100608 <panic>
  ismp = 1;
80103eea:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef4:	8b 40 24             	mov    0x24(%eax),%eax
80103ef7:	a3 1c 57 11 80       	mov    %eax,0x8011571c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eff:	83 c0 2c             	add    $0x2c,%eax
80103f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f08:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103f0c:	0f b7 d0             	movzwl %ax,%edx
80103f0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f12:	01 d0                	add    %edx,%eax
80103f14:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103f17:	e9 8c 00 00 00       	jmp    80103fa8 <mpinit+0xed>
    switch(*p){
80103f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1f:	0f b6 00             	movzbl (%eax),%eax
80103f22:	0f b6 c0             	movzbl %al,%eax
80103f25:	83 f8 04             	cmp    $0x4,%eax
80103f28:	7f 76                	jg     80103fa0 <mpinit+0xe5>
80103f2a:	83 f8 03             	cmp    $0x3,%eax
80103f2d:	7d 6b                	jge    80103f9a <mpinit+0xdf>
80103f2f:	83 f8 02             	cmp    $0x2,%eax
80103f32:	74 4e                	je     80103f82 <mpinit+0xc7>
80103f34:	83 f8 02             	cmp    $0x2,%eax
80103f37:	7f 67                	jg     80103fa0 <mpinit+0xe5>
80103f39:	85 c0                	test   %eax,%eax
80103f3b:	74 07                	je     80103f44 <mpinit+0x89>
80103f3d:	83 f8 01             	cmp    $0x1,%eax
80103f40:	74 58                	je     80103f9a <mpinit+0xdf>
80103f42:	eb 5c                	jmp    80103fa0 <mpinit+0xe5>
    case MPPROC:
      proc = (struct mpproc*)p;
80103f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f47:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103f4a:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103f4f:	83 f8 07             	cmp    $0x7,%eax
80103f52:	7f 28                	jg     80103f7c <mpinit+0xc1>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f54:	8b 15 a0 5d 11 80    	mov    0x80115da0,%edx
80103f5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f5d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f61:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103f67:	81 c2 20 58 11 80    	add    $0x80115820,%edx
80103f6d:	88 02                	mov    %al,(%edx)
        ncpu++;
80103f6f:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
80103f74:	83 c0 01             	add    $0x1,%eax
80103f77:	a3 a0 5d 11 80       	mov    %eax,0x80115da0
      }
      p += sizeof(struct mpproc);
80103f7c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103f80:	eb 26                	jmp    80103fa8 <mpinit+0xed>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103f88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f8b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103f8f:	a2 00 58 11 80       	mov    %al,0x80115800
      p += sizeof(struct mpioapic);
80103f94:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f98:	eb 0e                	jmp    80103fa8 <mpinit+0xed>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103f9a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103f9e:	eb 08                	jmp    80103fa8 <mpinit+0xed>
    default:
      ismp = 0;
80103fa0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103fa7:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fab:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103fae:	0f 82 68 ff ff ff    	jb     80103f1c <mpinit+0x61>
    }
  }
  if(!ismp)
80103fb4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fb8:	75 0d                	jne    80103fc7 <mpinit+0x10c>
    panic("Didn't find a suitable machine");
80103fba:	83 ec 0c             	sub    $0xc,%esp
80103fbd:	68 98 98 10 80       	push   $0x80109898
80103fc2:	e8 41 c6 ff ff       	call   80100608 <panic>

  if(mp->imcrp){
80103fc7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103fca:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103fce:	84 c0                	test   %al,%al
80103fd0:	74 30                	je     80104002 <mpinit+0x147>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103fd2:	83 ec 08             	sub    $0x8,%esp
80103fd5:	6a 70                	push   $0x70
80103fd7:	6a 22                	push   $0x22
80103fd9:	e8 ae fc ff ff       	call   80103c8c <outb>
80103fde:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103fe1:	83 ec 0c             	sub    $0xc,%esp
80103fe4:	6a 23                	push   $0x23
80103fe6:	e8 84 fc ff ff       	call   80103c6f <inb>
80103feb:	83 c4 10             	add    $0x10,%esp
80103fee:	83 c8 01             	or     $0x1,%eax
80103ff1:	0f b6 c0             	movzbl %al,%eax
80103ff4:	83 ec 08             	sub    $0x8,%esp
80103ff7:	50                   	push   %eax
80103ff8:	6a 23                	push   $0x23
80103ffa:	e8 8d fc ff ff       	call   80103c8c <outb>
80103fff:	83 c4 10             	add    $0x10,%esp
  }
}
80104002:	90                   	nop
80104003:	c9                   	leave  
80104004:	c3                   	ret    

80104005 <outb>:
{
80104005:	55                   	push   %ebp
80104006:	89 e5                	mov    %esp,%ebp
80104008:	83 ec 08             	sub    $0x8,%esp
8010400b:	8b 45 08             	mov    0x8(%ebp),%eax
8010400e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104011:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80104015:	89 d0                	mov    %edx,%eax
80104017:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010401a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010401e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104022:	ee                   	out    %al,(%dx)
}
80104023:	90                   	nop
80104024:	c9                   	leave  
80104025:	c3                   	ret    

80104026 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104026:	f3 0f 1e fb          	endbr32 
8010402a:	55                   	push   %ebp
8010402b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010402d:	68 ff 00 00 00       	push   $0xff
80104032:	6a 21                	push   $0x21
80104034:	e8 cc ff ff ff       	call   80104005 <outb>
80104039:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010403c:	68 ff 00 00 00       	push   $0xff
80104041:	68 a1 00 00 00       	push   $0xa1
80104046:	e8 ba ff ff ff       	call   80104005 <outb>
8010404b:	83 c4 08             	add    $0x8,%esp
}
8010404e:	90                   	nop
8010404f:	c9                   	leave  
80104050:	c3                   	ret    

80104051 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104051:	f3 0f 1e fb          	endbr32 
80104055:	55                   	push   %ebp
80104056:	89 e5                	mov    %esp,%ebp
80104058:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010405b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104062:	8b 45 0c             	mov    0xc(%ebp),%eax
80104065:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010406b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010406e:	8b 10                	mov    (%eax),%edx
80104070:	8b 45 08             	mov    0x8(%ebp),%eax
80104073:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104075:	e8 bc d0 ff ff       	call   80101136 <filealloc>
8010407a:	8b 55 08             	mov    0x8(%ebp),%edx
8010407d:	89 02                	mov    %eax,(%edx)
8010407f:	8b 45 08             	mov    0x8(%ebp),%eax
80104082:	8b 00                	mov    (%eax),%eax
80104084:	85 c0                	test   %eax,%eax
80104086:	0f 84 c8 00 00 00    	je     80104154 <pipealloc+0x103>
8010408c:	e8 a5 d0 ff ff       	call   80101136 <filealloc>
80104091:	8b 55 0c             	mov    0xc(%ebp),%edx
80104094:	89 02                	mov    %eax,(%edx)
80104096:	8b 45 0c             	mov    0xc(%ebp),%eax
80104099:	8b 00                	mov    (%eax),%eax
8010409b:	85 c0                	test   %eax,%eax
8010409d:	0f 84 b1 00 00 00    	je     80104154 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040a3:	e8 c4 ed ff ff       	call   80102e6c <kalloc>
801040a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040af:	0f 84 a2 00 00 00    	je     80104157 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
801040b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040bf:	00 00 00 
  p->writeopen = 1;
801040c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040cc:	00 00 00 
  p->nwrite = 0;
801040cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040d9:	00 00 00 
  p->nread = 0;
801040dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040df:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040e6:	00 00 00 
  initlock(&p->lock, "pipe");
801040e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ec:	83 ec 08             	sub    $0x8,%esp
801040ef:	68 b7 98 10 80       	push   $0x801098b7
801040f4:	50                   	push   %eax
801040f5:	e8 8f 13 00 00       	call   80105489 <initlock>
801040fa:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104100:	8b 00                	mov    (%eax),%eax
80104102:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104108:	8b 45 08             	mov    0x8(%ebp),%eax
8010410b:	8b 00                	mov    (%eax),%eax
8010410d:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104111:	8b 45 08             	mov    0x8(%ebp),%eax
80104114:	8b 00                	mov    (%eax),%eax
80104116:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010411a:	8b 45 08             	mov    0x8(%ebp),%eax
8010411d:	8b 00                	mov    (%eax),%eax
8010411f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104122:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104125:	8b 45 0c             	mov    0xc(%ebp),%eax
80104128:	8b 00                	mov    (%eax),%eax
8010412a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104130:	8b 45 0c             	mov    0xc(%ebp),%eax
80104133:	8b 00                	mov    (%eax),%eax
80104135:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010413c:	8b 00                	mov    (%eax),%eax
8010413e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104142:	8b 45 0c             	mov    0xc(%ebp),%eax
80104145:	8b 00                	mov    (%eax),%eax
80104147:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010414a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010414d:	b8 00 00 00 00       	mov    $0x0,%eax
80104152:	eb 51                	jmp    801041a5 <pipealloc+0x154>
    goto bad;
80104154:	90                   	nop
80104155:	eb 01                	jmp    80104158 <pipealloc+0x107>
    goto bad;
80104157:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104158:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010415c:	74 0e                	je     8010416c <pipealloc+0x11b>
    kfree((char*)p);
8010415e:	83 ec 0c             	sub    $0xc,%esp
80104161:	ff 75 f4             	pushl  -0xc(%ebp)
80104164:	e8 65 ec ff ff       	call   80102dce <kfree>
80104169:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	8b 00                	mov    (%eax),%eax
80104171:	85 c0                	test   %eax,%eax
80104173:	74 11                	je     80104186 <pipealloc+0x135>
    fileclose(*f0);
80104175:	8b 45 08             	mov    0x8(%ebp),%eax
80104178:	8b 00                	mov    (%eax),%eax
8010417a:	83 ec 0c             	sub    $0xc,%esp
8010417d:	50                   	push   %eax
8010417e:	e8 79 d0 ff ff       	call   801011fc <fileclose>
80104183:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104186:	8b 45 0c             	mov    0xc(%ebp),%eax
80104189:	8b 00                	mov    (%eax),%eax
8010418b:	85 c0                	test   %eax,%eax
8010418d:	74 11                	je     801041a0 <pipealloc+0x14f>
    fileclose(*f1);
8010418f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104192:	8b 00                	mov    (%eax),%eax
80104194:	83 ec 0c             	sub    $0xc,%esp
80104197:	50                   	push   %eax
80104198:	e8 5f d0 ff ff       	call   801011fc <fileclose>
8010419d:	83 c4 10             	add    $0x10,%esp
  return -1;
801041a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041a5:	c9                   	leave  
801041a6:	c3                   	ret    

801041a7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041a7:	f3 0f 1e fb          	endbr32 
801041ab:	55                   	push   %ebp
801041ac:	89 e5                	mov    %esp,%ebp
801041ae:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041b1:	8b 45 08             	mov    0x8(%ebp),%eax
801041b4:	83 ec 0c             	sub    $0xc,%esp
801041b7:	50                   	push   %eax
801041b8:	e8 f2 12 00 00       	call   801054af <acquire>
801041bd:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041c4:	74 23                	je     801041e9 <pipeclose+0x42>
    p->writeopen = 0;
801041c6:	8b 45 08             	mov    0x8(%ebp),%eax
801041c9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041d0:	00 00 00 
    wakeup(&p->nread);
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	05 34 02 00 00       	add    $0x234,%eax
801041db:	83 ec 0c             	sub    $0xc,%esp
801041de:	50                   	push   %eax
801041df:	e8 4b 0f 00 00       	call   8010512f <wakeup>
801041e4:	83 c4 10             	add    $0x10,%esp
801041e7:	eb 21                	jmp    8010420a <pipeclose+0x63>
  } else {
    p->readopen = 0;
801041e9:	8b 45 08             	mov    0x8(%ebp),%eax
801041ec:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041f3:	00 00 00 
    wakeup(&p->nwrite);
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	05 38 02 00 00       	add    $0x238,%eax
801041fe:	83 ec 0c             	sub    $0xc,%esp
80104201:	50                   	push   %eax
80104202:	e8 28 0f 00 00       	call   8010512f <wakeup>
80104207:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010420a:	8b 45 08             	mov    0x8(%ebp),%eax
8010420d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104213:	85 c0                	test   %eax,%eax
80104215:	75 2c                	jne    80104243 <pipeclose+0x9c>
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104220:	85 c0                	test   %eax,%eax
80104222:	75 1f                	jne    80104243 <pipeclose+0x9c>
    release(&p->lock);
80104224:	8b 45 08             	mov    0x8(%ebp),%eax
80104227:	83 ec 0c             	sub    $0xc,%esp
8010422a:	50                   	push   %eax
8010422b:	e8 f1 12 00 00       	call   80105521 <release>
80104230:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104233:	83 ec 0c             	sub    $0xc,%esp
80104236:	ff 75 08             	pushl  0x8(%ebp)
80104239:	e8 90 eb ff ff       	call   80102dce <kfree>
8010423e:	83 c4 10             	add    $0x10,%esp
80104241:	eb 10                	jmp    80104253 <pipeclose+0xac>
  } else
    release(&p->lock);
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	83 ec 0c             	sub    $0xc,%esp
80104249:	50                   	push   %eax
8010424a:	e8 d2 12 00 00       	call   80105521 <release>
8010424f:	83 c4 10             	add    $0x10,%esp
}
80104252:	90                   	nop
80104253:	90                   	nop
80104254:	c9                   	leave  
80104255:	c3                   	ret    

80104256 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104256:	f3 0f 1e fb          	endbr32 
8010425a:	55                   	push   %ebp
8010425b:	89 e5                	mov    %esp,%ebp
8010425d:	53                   	push   %ebx
8010425e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104261:	8b 45 08             	mov    0x8(%ebp),%eax
80104264:	83 ec 0c             	sub    $0xc,%esp
80104267:	50                   	push   %eax
80104268:	e8 42 12 00 00       	call   801054af <acquire>
8010426d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104270:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104277:	e9 ad 00 00 00       	jmp    80104329 <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104285:	85 c0                	test   %eax,%eax
80104287:	74 0c                	je     80104295 <pipewrite+0x3f>
80104289:	e8 a2 02 00 00       	call   80104530 <myproc>
8010428e:	8b 40 24             	mov    0x24(%eax),%eax
80104291:	85 c0                	test   %eax,%eax
80104293:	74 19                	je     801042ae <pipewrite+0x58>
        release(&p->lock);
80104295:	8b 45 08             	mov    0x8(%ebp),%eax
80104298:	83 ec 0c             	sub    $0xc,%esp
8010429b:	50                   	push   %eax
8010429c:	e8 80 12 00 00       	call   80105521 <release>
801042a1:	83 c4 10             	add    $0x10,%esp
        return -1;
801042a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a9:	e9 a9 00 00 00       	jmp    80104357 <pipewrite+0x101>
      }
      wakeup(&p->nread);
801042ae:	8b 45 08             	mov    0x8(%ebp),%eax
801042b1:	05 34 02 00 00       	add    $0x234,%eax
801042b6:	83 ec 0c             	sub    $0xc,%esp
801042b9:	50                   	push   %eax
801042ba:	e8 70 0e 00 00       	call   8010512f <wakeup>
801042bf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042c2:	8b 45 08             	mov    0x8(%ebp),%eax
801042c5:	8b 55 08             	mov    0x8(%ebp),%edx
801042c8:	81 c2 38 02 00 00    	add    $0x238,%edx
801042ce:	83 ec 08             	sub    $0x8,%esp
801042d1:	50                   	push   %eax
801042d2:	52                   	push   %edx
801042d3:	e8 65 0d 00 00       	call   8010503d <sleep>
801042d8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042e4:	8b 45 08             	mov    0x8(%ebp),%eax
801042e7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042ed:	05 00 02 00 00       	add    $0x200,%eax
801042f2:	39 c2                	cmp    %eax,%edx
801042f4:	74 86                	je     8010427c <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fc:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104302:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104308:	8d 48 01             	lea    0x1(%eax),%ecx
8010430b:	8b 55 08             	mov    0x8(%ebp),%edx
8010430e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104314:	25 ff 01 00 00       	and    $0x1ff,%eax
80104319:	89 c1                	mov    %eax,%ecx
8010431b:	0f b6 13             	movzbl (%ebx),%edx
8010431e:	8b 45 08             	mov    0x8(%ebp),%eax
80104321:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104325:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010432f:	7c aa                	jl     801042db <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104331:	8b 45 08             	mov    0x8(%ebp),%eax
80104334:	05 34 02 00 00       	add    $0x234,%eax
80104339:	83 ec 0c             	sub    $0xc,%esp
8010433c:	50                   	push   %eax
8010433d:	e8 ed 0d 00 00       	call   8010512f <wakeup>
80104342:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104345:	8b 45 08             	mov    0x8(%ebp),%eax
80104348:	83 ec 0c             	sub    $0xc,%esp
8010434b:	50                   	push   %eax
8010434c:	e8 d0 11 00 00       	call   80105521 <release>
80104351:	83 c4 10             	add    $0x10,%esp
  return n;
80104354:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104357:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010435a:	c9                   	leave  
8010435b:	c3                   	ret    

8010435c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010435c:	f3 0f 1e fb          	endbr32 
80104360:	55                   	push   %ebp
80104361:	89 e5                	mov    %esp,%ebp
80104363:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104366:	8b 45 08             	mov    0x8(%ebp),%eax
80104369:	83 ec 0c             	sub    $0xc,%esp
8010436c:	50                   	push   %eax
8010436d:	e8 3d 11 00 00       	call   801054af <acquire>
80104372:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104375:	eb 3e                	jmp    801043b5 <piperead+0x59>
    if(myproc()->killed){
80104377:	e8 b4 01 00 00       	call   80104530 <myproc>
8010437c:	8b 40 24             	mov    0x24(%eax),%eax
8010437f:	85 c0                	test   %eax,%eax
80104381:	74 19                	je     8010439c <piperead+0x40>
      release(&p->lock);
80104383:	8b 45 08             	mov    0x8(%ebp),%eax
80104386:	83 ec 0c             	sub    $0xc,%esp
80104389:	50                   	push   %eax
8010438a:	e8 92 11 00 00       	call   80105521 <release>
8010438f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104397:	e9 be 00 00 00       	jmp    8010445a <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010439c:	8b 45 08             	mov    0x8(%ebp),%eax
8010439f:	8b 55 08             	mov    0x8(%ebp),%edx
801043a2:	81 c2 34 02 00 00    	add    $0x234,%edx
801043a8:	83 ec 08             	sub    $0x8,%esp
801043ab:	50                   	push   %eax
801043ac:	52                   	push   %edx
801043ad:	e8 8b 0c 00 00       	call   8010503d <sleep>
801043b2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043b5:	8b 45 08             	mov    0x8(%ebp),%eax
801043b8:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043be:	8b 45 08             	mov    0x8(%ebp),%eax
801043c1:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043c7:	39 c2                	cmp    %eax,%edx
801043c9:	75 0d                	jne    801043d8 <piperead+0x7c>
801043cb:	8b 45 08             	mov    0x8(%ebp),%eax
801043ce:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043d4:	85 c0                	test   %eax,%eax
801043d6:	75 9f                	jne    80104377 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043df:	eb 48                	jmp    80104429 <piperead+0xcd>
    if(p->nread == p->nwrite)
801043e1:	8b 45 08             	mov    0x8(%ebp),%eax
801043e4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043ea:	8b 45 08             	mov    0x8(%ebp),%eax
801043ed:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043f3:	39 c2                	cmp    %eax,%edx
801043f5:	74 3c                	je     80104433 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043f7:	8b 45 08             	mov    0x8(%ebp),%eax
801043fa:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104400:	8d 48 01             	lea    0x1(%eax),%ecx
80104403:	8b 55 08             	mov    0x8(%ebp),%edx
80104406:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010440c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104411:	89 c1                	mov    %eax,%ecx
80104413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104416:	8b 45 0c             	mov    0xc(%ebp),%eax
80104419:	01 c2                	add    %eax,%edx
8010441b:	8b 45 08             	mov    0x8(%ebp),%eax
8010441e:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104423:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104425:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010442f:	7c b0                	jl     801043e1 <piperead+0x85>
80104431:	eb 01                	jmp    80104434 <piperead+0xd8>
      break;
80104433:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104434:	8b 45 08             	mov    0x8(%ebp),%eax
80104437:	05 38 02 00 00       	add    $0x238,%eax
8010443c:	83 ec 0c             	sub    $0xc,%esp
8010443f:	50                   	push   %eax
80104440:	e8 ea 0c 00 00       	call   8010512f <wakeup>
80104445:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104448:	8b 45 08             	mov    0x8(%ebp),%eax
8010444b:	83 ec 0c             	sub    $0xc,%esp
8010444e:	50                   	push   %eax
8010444f:	e8 cd 10 00 00       	call   80105521 <release>
80104454:	83 c4 10             	add    $0x10,%esp
  return i;
80104457:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010445a:	c9                   	leave  
8010445b:	c3                   	ret    

8010445c <readeflags>:
{
8010445c:	55                   	push   %ebp
8010445d:	89 e5                	mov    %esp,%ebp
8010445f:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104462:	9c                   	pushf  
80104463:	58                   	pop    %eax
80104464:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104467:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010446a:	c9                   	leave  
8010446b:	c3                   	ret    

8010446c <sti>:
{
8010446c:	55                   	push   %ebp
8010446d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010446f:	fb                   	sti    
}
80104470:	90                   	nop
80104471:	5d                   	pop    %ebp
80104472:	c3                   	ret    

80104473 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104473:	f3 0f 1e fb          	endbr32 
80104477:	55                   	push   %ebp
80104478:	89 e5                	mov    %esp,%ebp
8010447a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010447d:	83 ec 08             	sub    $0x8,%esp
80104480:	68 bc 98 10 80       	push   $0x801098bc
80104485:	68 c0 5d 11 80       	push   $0x80115dc0
8010448a:	e8 fa 0f 00 00       	call   80105489 <initlock>
8010448f:	83 c4 10             	add    $0x10,%esp
}
80104492:	90                   	nop
80104493:	c9                   	leave  
80104494:	c3                   	ret    

80104495 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104495:	f3 0f 1e fb          	endbr32 
80104499:	55                   	push   %ebp
8010449a:	89 e5                	mov    %esp,%ebp
8010449c:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010449f:	e8 10 00 00 00       	call   801044b4 <mycpu>
801044a4:	2d 20 58 11 80       	sub    $0x80115820,%eax
801044a9:	c1 f8 04             	sar    $0x4,%eax
801044ac:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801044b2:	c9                   	leave  
801044b3:	c3                   	ret    

801044b4 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801044b4:	f3 0f 1e fb          	endbr32 
801044b8:	55                   	push   %ebp
801044b9:	89 e5                	mov    %esp,%ebp
801044bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801044be:	e8 99 ff ff ff       	call   8010445c <readeflags>
801044c3:	25 00 02 00 00       	and    $0x200,%eax
801044c8:	85 c0                	test   %eax,%eax
801044ca:	74 0d                	je     801044d9 <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
801044cc:	83 ec 0c             	sub    $0xc,%esp
801044cf:	68 c4 98 10 80       	push   $0x801098c4
801044d4:	e8 2f c1 ff ff       	call   80100608 <panic>
  
  apicid = lapicid();
801044d9:	e8 21 ed ff ff       	call   801031ff <lapicid>
801044de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044e8:	eb 2d                	jmp    80104517 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801044ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801044f3:	05 20 58 11 80       	add    $0x80115820,%eax
801044f8:	0f b6 00             	movzbl (%eax),%eax
801044fb:	0f b6 c0             	movzbl %al,%eax
801044fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104501:	75 10                	jne    80104513 <mycpu+0x5f>
      return &cpus[i];
80104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104506:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010450c:	05 20 58 11 80       	add    $0x80115820,%eax
80104511:	eb 1b                	jmp    8010452e <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104513:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104517:	a1 a0 5d 11 80       	mov    0x80115da0,%eax
8010451c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010451f:	7c c9                	jl     801044ea <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104521:	83 ec 0c             	sub    $0xc,%esp
80104524:	68 ea 98 10 80       	push   $0x801098ea
80104529:	e8 da c0 ff ff       	call   80100608 <panic>
}
8010452e:	c9                   	leave  
8010452f:	c3                   	ret    

80104530 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104530:	f3 0f 1e fb          	endbr32 
80104534:	55                   	push   %ebp
80104535:	89 e5                	mov    %esp,%ebp
80104537:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010453a:	e8 fc 10 00 00       	call   8010563b <pushcli>
  c = mycpu();
8010453f:	e8 70 ff ff ff       	call   801044b4 <mycpu>
80104544:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104550:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104553:	e8 34 11 00 00       	call   8010568c <popcli>
  return p;
80104558:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010455b:	c9                   	leave  
8010455c:	c3                   	ret    

8010455d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010455d:	f3 0f 1e fb          	endbr32 
80104561:	55                   	push   %ebp
80104562:	89 e5                	mov    %esp,%ebp
80104564:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104567:	83 ec 0c             	sub    $0xc,%esp
8010456a:	68 c0 5d 11 80       	push   $0x80115dc0
8010456f:	e8 3b 0f 00 00       	call   801054af <acquire>
80104574:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104577:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
8010457e:	eb 11                	jmp    80104591 <allocproc+0x34>
    if(p->state == UNUSED)
80104580:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104583:	8b 40 0c             	mov    0xc(%eax),%eax
80104586:	85 c0                	test   %eax,%eax
80104588:	74 2a                	je     801045b4 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010458a:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104591:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104598:	72 e6                	jb     80104580 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010459a:	83 ec 0c             	sub    $0xc,%esp
8010459d:	68 c0 5d 11 80       	push   $0x80115dc0
801045a2:	e8 7a 0f 00 00       	call   80105521 <release>
801045a7:	83 c4 10             	add    $0x10,%esp
  return 0;
801045aa:	b8 00 00 00 00       	mov    $0x0,%eax
801045af:	e9 f7 00 00 00       	jmp    801046ab <allocproc+0x14e>
      goto found;
801045b4:	90                   	nop
801045b5:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
801045b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bc:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801045c3:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801045c8:	8d 50 01             	lea    0x1(%eax),%edx
801045cb:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
801045d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045d4:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045d7:	83 ec 0c             	sub    $0xc,%esp
801045da:	68 c0 5d 11 80       	push   $0x80115dc0
801045df:	e8 3d 0f 00 00       	call   80105521 <release>
801045e4:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045e7:	e8 80 e8 ff ff       	call   80102e6c <kalloc>
801045ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ef:	89 42 08             	mov    %eax,0x8(%edx)
801045f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f5:	8b 40 08             	mov    0x8(%eax),%eax
801045f8:	85 c0                	test   %eax,%eax
801045fa:	75 14                	jne    80104610 <allocproc+0xb3>
    p->state = UNUSED;
801045fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ff:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104606:	b8 00 00 00 00       	mov    $0x0,%eax
8010460b:	e9 9b 00 00 00       	jmp    801046ab <allocproc+0x14e>
  }
  sp = p->kstack + KSTACKSIZE;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	8b 40 08             	mov    0x8(%eax),%eax
80104616:	05 00 10 00 00       	add    $0x1000,%eax
8010461b:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010461e:	83 6d ec 4c          	subl   $0x4c,-0x14(%ebp)
  p->tf = (struct trapframe*)sp;
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104628:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010462b:	83 6d ec 04          	subl   $0x4,-0x14(%ebp)
  *(uint*)sp = (uint)trapret;
8010462f:	ba c4 6c 10 80       	mov    $0x80106cc4,%edx
80104634:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104637:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104639:	83 6d ec 14          	subl   $0x14,-0x14(%ebp)
  p->context = (struct context*)sp;
8010463d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104640:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104643:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104649:	8b 40 1c             	mov    0x1c(%eax),%eax
8010464c:	83 ec 04             	sub    $0x4,%esp
8010464f:	6a 14                	push   $0x14
80104651:	6a 00                	push   $0x0
80104653:	50                   	push   %eax
80104654:	e8 f5 10 00 00       	call   8010574e <memset>
80104659:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104662:	ba f3 4f 10 80       	mov    $0x80104ff3,%edx
80104667:	89 50 10             	mov    %edx,0x10(%eax)

  //Our changes initilize variables
  p->counter = 0;
8010466a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466d:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80104674:	00 00 00 
  p->clock_size = 0;
80104677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467a:	c7 80 a0 00 00 00 00 	movl   $0x0,0xa0(%eax)
80104681:	00 00 00 
  for(int i = 0; i < CLOCKSIZE; i ++)
80104684:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010468b:	eb 15                	jmp    801046a2 <allocproc+0x145>
  {
      p->clock_array[i] = 0;
8010468d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104690:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104693:	83 c2 1c             	add    $0x1c,%edx
80104696:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010469d:	00 
  for(int i = 0; i < CLOCKSIZE; i ++)
8010469e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801046a2:	83 7d f0 07          	cmpl   $0x7,-0x10(%ebp)
801046a6:	7e e5                	jle    8010468d <allocproc+0x130>
  }
  return p;
801046a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ab:	c9                   	leave  
801046ac:	c3                   	ret    

801046ad <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801046ad:	f3 0f 1e fb          	endbr32 
801046b1:	55                   	push   %ebp
801046b2:	89 e5                	mov    %esp,%ebp
801046b4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801046b7:	e8 a1 fe ff ff       	call   8010455d <allocproc>
801046bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c2:	a3 40 d6 10 80       	mov    %eax,0x8010d640
  if((p->pgdir = setupkvm()) == 0)
801046c7:	e8 d8 3b 00 00       	call   801082a4 <setupkvm>
801046cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046cf:	89 42 04             	mov    %eax,0x4(%edx)
801046d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d5:	8b 40 04             	mov    0x4(%eax),%eax
801046d8:	85 c0                	test   %eax,%eax
801046da:	75 0d                	jne    801046e9 <userinit+0x3c>
    panic("userinit: out of memory?");
801046dc:	83 ec 0c             	sub    $0xc,%esp
801046df:	68 fa 98 10 80       	push   $0x801098fa
801046e4:	e8 1f bf ff ff       	call   80100608 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046e9:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f1:	8b 40 04             	mov    0x4(%eax),%eax
801046f4:	83 ec 04             	sub    $0x4,%esp
801046f7:	52                   	push   %edx
801046f8:	68 e0 d4 10 80       	push   $0x8010d4e0
801046fd:	50                   	push   %eax
801046fe:	e8 1a 3e 00 00       	call   8010851d <inituvm>
80104703:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104709:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010470f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104712:	8b 40 18             	mov    0x18(%eax),%eax
80104715:	83 ec 04             	sub    $0x4,%esp
80104718:	6a 4c                	push   $0x4c
8010471a:	6a 00                	push   $0x0
8010471c:	50                   	push   %eax
8010471d:	e8 2c 10 00 00       	call   8010574e <memset>
80104722:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104728:	8b 40 18             	mov    0x18(%eax),%eax
8010472b:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104734:	8b 40 18             	mov    0x18(%eax),%eax
80104737:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010473d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104740:	8b 50 18             	mov    0x18(%eax),%edx
80104743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104746:	8b 40 18             	mov    0x18(%eax),%eax
80104749:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010474d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104754:	8b 50 18             	mov    0x18(%eax),%edx
80104757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475a:	8b 40 18             	mov    0x18(%eax),%eax
8010475d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104761:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104768:	8b 40 18             	mov    0x18(%eax),%eax
8010476b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104775:	8b 40 18             	mov    0x18(%eax),%eax
80104778:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010477f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104782:	8b 40 18             	mov    0x18(%eax),%eax
80104785:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010478c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478f:	83 c0 6c             	add    $0x6c,%eax
80104792:	83 ec 04             	sub    $0x4,%esp
80104795:	6a 10                	push   $0x10
80104797:	68 13 99 10 80       	push   $0x80109913
8010479c:	50                   	push   %eax
8010479d:	e8 c7 11 00 00       	call   80105969 <safestrcpy>
801047a2:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801047a5:	83 ec 0c             	sub    $0xc,%esp
801047a8:	68 1c 99 10 80       	push   $0x8010991c
801047ad:	e8 35 df ff ff       	call   801026e7 <namei>
801047b2:	83 c4 10             	add    $0x10,%esp
801047b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047b8:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801047bb:	83 ec 0c             	sub    $0xc,%esp
801047be:	68 c0 5d 11 80       	push   $0x80115dc0
801047c3:	e8 e7 0c 00 00       	call   801054af <acquire>
801047c8:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801047cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ce:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047d5:	83 ec 0c             	sub    $0xc,%esp
801047d8:	68 c0 5d 11 80       	push   $0x80115dc0
801047dd:	e8 3f 0d 00 00       	call   80105521 <release>
801047e2:	83 c4 10             	add    $0x10,%esp
}
801047e5:	90                   	nop
801047e6:	c9                   	leave  
801047e7:	c3                   	ret    

801047e8 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801047e8:	f3 0f 1e fb          	endbr32 
801047ec:	55                   	push   %ebp
801047ed:	89 e5                	mov    %esp,%ebp
801047ef:	83 ec 38             	sub    $0x38,%esp
  uint sz;
  struct proc *curproc = myproc();
801047f2:	e8 39 fd ff ff       	call   80104530 <myproc>
801047f7:	89 45 e0             	mov    %eax,-0x20(%ebp)

  sz = curproc->sz;
801047fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fd:	8b 00                	mov    (%eax),%eax
801047ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104802:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104806:	7e 6a                	jle    80104872 <growproc+0x8a>
    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104808:	8b 55 08             	mov    0x8(%ebp),%edx
8010480b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480e:	01 c2                	add    %eax,%edx
80104810:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104813:	8b 40 04             	mov    0x4(%eax),%eax
80104816:	83 ec 04             	sub    $0x4,%esp
80104819:	52                   	push   %edx
8010481a:	ff 75 f4             	pushl  -0xc(%ebp)
8010481d:	50                   	push   %eax
8010481e:	e8 3f 3e 00 00       	call   80108662 <allocuvm>
80104823:	83 c4 10             	add    $0x10,%esp
80104826:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104829:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010482d:	75 0a                	jne    80104839 <growproc+0x51>
      return -1;
8010482f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104834:	e9 fe 01 00 00       	jmp    80104a37 <growproc+0x24f>
    mencrypt((char*) PGROUNDDOWN(curproc->sz), (PGROUNDDOWN(sz) - PGROUNDDOWN(curproc->sz))/PGSIZE);
80104839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104841:	89 c2                	mov    %eax,%edx
80104843:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104846:	8b 00                	mov    (%eax),%eax
80104848:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010484d:	29 c2                	sub    %eax,%edx
8010484f:	89 d0                	mov    %edx,%eax
80104851:	c1 e8 0c             	shr    $0xc,%eax
80104854:	89 c2                	mov    %eax,%edx
80104856:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104859:	8b 00                	mov    (%eax),%eax
8010485b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104860:	83 ec 08             	sub    $0x8,%esp
80104863:	52                   	push   %edx
80104864:	50                   	push   %eax
80104865:	e8 8c 47 00 00       	call   80108ff6 <mencrypt>
8010486a:	83 c4 10             	add    $0x10,%esp
8010486d:	e9 aa 01 00 00       	jmp    80104a1c <growproc+0x234>
  }
 else if(n < 0){
80104872:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104876:	0f 89 a0 01 00 00    	jns    80104a1c <growproc+0x234>
   cprintf("trying to dealloc in growproc.................................................................\n");
8010487c:	83 ec 0c             	sub    $0xc,%esp
8010487f:	68 20 99 10 80       	push   $0x80109920
80104884:	e8 8f bb ff ff       	call   80100418 <cprintf>
80104889:	83 c4 10             	add    $0x10,%esp
   cprintf("CLOCKSIZE = %x", curproc->clock_size);
8010488c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010488f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80104895:	83 ec 08             	sub    $0x8,%esp
80104898:	50                   	push   %eax
80104899:	68 80 99 10 80       	push   $0x80109980
8010489e:	e8 75 bb ff ff       	call   80100418 <cprintf>
801048a3:	83 c4 10             	add    $0x10,%esp
   if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801048a6:	8b 55 08             	mov    0x8(%ebp),%edx
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	01 c2                	add    %eax,%edx
801048ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b1:	8b 40 04             	mov    0x4(%eax),%eax
801048b4:	83 ec 04             	sub    $0x4,%esp
801048b7:	52                   	push   %edx
801048b8:	ff 75 f4             	pushl  -0xc(%ebp)
801048bb:	50                   	push   %eax
801048bc:	e8 aa 3e 00 00       	call   8010876b <deallocuvm>
801048c1:	83 c4 10             	add    $0x10,%esp
801048c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048cb:	75 0a                	jne    801048d7 <growproc+0xef>
      return -1;
801048cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048d2:	e9 60 01 00 00       	jmp    80104a37 <growproc+0x24f>
  
   char* start_add = (char*)(sz);
801048d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048da:	89 45 dc             	mov    %eax,-0x24(%ebp)
   char* end_add = (char*)PGROUNDUP(sz-n);
801048dd:	8b 45 08             	mov    0x8(%ebp),%eax
801048e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048e3:	29 c2                	sub    %eax,%edx
801048e5:	89 d0                	mov    %edx,%eax
801048e7:	05 ff 0f 00 00       	add    $0xfff,%eax
801048ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801048f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
   uint uva =(PGROUNDDOWN((uint)start_add));
801048f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801048fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
   uint end_uva = PGROUNDDOWN((uint)end_add);
801048ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104902:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80104907:	89 45 d4             	mov    %eax,-0x2c(%ebp)
   while(uva < end_uva){
8010490a:	e9 d0 00 00 00       	jmp    801049df <growproc+0x1f7>
      //mencrypt((char*) PGROUNDUP(curproc->sz), (PGROUNDUP(curproc->sz)- PGROUNDUP(sz)));
      char* va = (char*)uva; //not sure
8010490f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104912:	89 45 d0             	mov    %eax,-0x30(%ebp)
      cprintf("THIS IS THE UVA ........................... %x\n", va);
80104915:	83 ec 08             	sub    $0x8,%esp
80104918:	ff 75 d0             	pushl  -0x30(%ebp)
8010491b:	68 90 99 10 80       	push   $0x80109990
80104920:	e8 f3 ba ff ff       	call   80100418 <cprintf>
80104925:	83 c4 10             	add    $0x10,%esp
      //mencrypt(va, 1);
      for(int k = 0; k < CLOCKSIZE; k++){
80104928:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010492f:	e9 9a 00 00 00       	jmp    801049ce <growproc+0x1e6>
        if(curproc->clock_array[k] ==(char*) PGROUNDDOWN((uint)va)){
80104934:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104937:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010493a:	83 c2 1c             	add    $0x1c,%edx
8010493d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104941:	8b 55 d0             	mov    -0x30(%ebp),%edx
80104944:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010494a:	39 d0                	cmp    %edx,%eax
8010494c:	75 7c                	jne    801049ca <growproc+0x1e2>
        cprintf("FOUND -------------------------------------------------------\n");
8010494e:	83 ec 0c             	sub    $0xc,%esp
80104951:	68 c0 99 10 80       	push   $0x801099c0
80104956:	e8 bd ba ff ff       	call   80100418 <cprintf>
8010495b:	83 c4 10             	add    $0x10,%esp
          mencrypt(curproc->clock_array[k], 1);
8010495e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104961:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104964:	83 c2 1c             	add    $0x1c,%edx
80104967:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010496b:	83 ec 08             	sub    $0x8,%esp
8010496e:	6a 01                	push   $0x1
80104970:	50                   	push   %eax
80104971:	e8 80 46 00 00       	call   80108ff6 <mencrypt>
80104976:	83 c4 10             	add    $0x10,%esp
        
//        pte_t* mypd = curproc->pgdir;
  //      pte_t* pteTarget = walkpgdir(mypd, curproc->clock_array[k], 0);
    //    *pteTarget = *pteTarget & ~PTE_A;
          
        for(int j = k; j+1 < CLOCKSIZE; j++){
80104979:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010497c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010497f:	eb 21                	jmp    801049a2 <growproc+0x1ba>
             curproc->clock_array[j] = curproc->clock_array[j+1];
80104981:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104984:	8d 50 01             	lea    0x1(%eax),%edx
80104987:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010498a:	83 c2 1c             	add    $0x1c,%edx
8010498d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80104991:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104994:	8b 4d e8             	mov    -0x18(%ebp),%ecx
80104997:	83 c1 1c             	add    $0x1c,%ecx
8010499a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
        for(int j = k; j+1 < CLOCKSIZE; j++){
8010499e:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
801049a2:	83 7d e8 06          	cmpl   $0x6,-0x18(%ebp)
801049a6:	7e d9                	jle    80104981 <growproc+0x199>
             
          }
          curproc->clock_array[CLOCKSIZE - 1] =(char*) -1;
801049a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ab:	c7 80 98 00 00 00 ff 	movl   $0xffffffff,0x98(%eax)
801049b2:	ff ff ff 
          
          curproc->clock_size--;
801049b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801049be:	8d 50 ff             	lea    -0x1(%eax),%edx
801049c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c4:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
      for(int k = 0; k < CLOCKSIZE; k++){
801049ca:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801049ce:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
801049d2:	0f 8e 5c ff ff ff    	jle    80104934 <growproc+0x14c>
         // curproc->counter--;
        }
      }
        uva+=PGSIZE;
801049d8:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
   while(uva < end_uva){
801049df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e2:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
801049e5:	0f 82 24 ff ff ff    	jb     8010490f <growproc+0x127>
   }

   for (int i = 0; i < CLOCKSIZE; i++){
801049eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801049f2:	eb 22                	jmp    80104a16 <growproc+0x22e>
    cprintf("AFTER  dealloc queue + %x---------------------------------------\n", curproc -> clock_array[i]);
801049f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049fa:	83 c2 1c             	add    $0x1c,%edx
801049fd:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104a01:	83 ec 08             	sub    $0x8,%esp
80104a04:	50                   	push   %eax
80104a05:	68 00 9a 10 80       	push   $0x80109a00
80104a0a:	e8 09 ba ff ff       	call   80100418 <cprintf>
80104a0f:	83 c4 10             	add    $0x10,%esp
   for (int i = 0; i < CLOCKSIZE; i++){
80104a12:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104a16:	83 7d e4 07          	cmpl   $0x7,-0x1c(%ebp)
80104a1a:	7e d8                	jle    801049f4 <growproc+0x20c>
    }
 
 }
 // mencrypt((char*) curproc->sz, n / PGSIZE);
  curproc->sz = sz;
80104a1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a22:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104a24:	83 ec 0c             	sub    $0xc,%esp
80104a27:	ff 75 e0             	pushl  -0x20(%ebp)
80104a2a:	e8 4b 39 00 00       	call   8010837a <switchuvm>
80104a2f:	83 c4 10             	add    $0x10,%esp
  return 0;
80104a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a37:	c9                   	leave  
80104a38:	c3                   	ret    

80104a39 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104a39:	f3 0f 1e fb          	endbr32 
80104a3d:	55                   	push   %ebp
80104a3e:	89 e5                	mov    %esp,%ebp
80104a40:	57                   	push   %edi
80104a41:	56                   	push   %esi
80104a42:	53                   	push   %ebx
80104a43:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104a46:	e8 e5 fa ff ff       	call   80104530 <myproc>
80104a4b:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104a4e:	e8 0a fb ff ff       	call   8010455d <allocproc>
80104a53:	89 45 d8             	mov    %eax,-0x28(%ebp)
80104a56:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80104a5a:	75 0a                	jne    80104a66 <fork+0x2d>
    return -1;
80104a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a61:	e9 7d 01 00 00       	jmp    80104be3 <fork+0x1aa>
  }
  //*buffer = *buffer;
  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104a66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a69:	8b 10                	mov    (%eax),%edx
80104a6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a6e:	8b 40 04             	mov    0x4(%eax),%eax
80104a71:	83 ec 08             	sub    $0x8,%esp
80104a74:	52                   	push   %edx
80104a75:	50                   	push   %eax
80104a76:	e8 9e 3e 00 00       	call   80108919 <copyuvm>
80104a7b:	83 c4 10             	add    $0x10,%esp
80104a7e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104a81:	89 42 04             	mov    %eax,0x4(%edx)
80104a84:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a87:	8b 40 04             	mov    0x4(%eax),%eax
80104a8a:	85 c0                	test   %eax,%eax
80104a8c:	75 30                	jne    80104abe <fork+0x85>
    kfree(np->kstack);
80104a8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104a91:	8b 40 08             	mov    0x8(%eax),%eax
80104a94:	83 ec 0c             	sub    $0xc,%esp
80104a97:	50                   	push   %eax
80104a98:	e8 31 e3 ff ff       	call   80102dce <kfree>
80104a9d:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104aa0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104aa3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104aaa:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104aad:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ab9:	e9 25 01 00 00       	jmp    80104be3 <fork+0x1aa>
  }
  np->sz = curproc->sz;
80104abe:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104ac1:	8b 10                	mov    (%eax),%edx
80104ac3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104ac6:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104ac8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104acb:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104ace:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104ad1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104ad4:	8b 48 18             	mov    0x18(%eax),%ecx
80104ad7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104ada:	8b 40 18             	mov    0x18(%eax),%eax
80104add:	89 c2                	mov    %eax,%edx
80104adf:	89 cb                	mov    %ecx,%ebx
80104ae1:	b8 13 00 00 00       	mov    $0x13,%eax
80104ae6:	89 d7                	mov    %edx,%edi
80104ae8:	89 de                	mov    %ebx,%esi
80104aea:	89 c1                	mov    %eax,%ecx
80104aec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  
    // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104af1:	8b 40 18             	mov    0x18(%eax),%eax
80104af4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104afb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104b02:	eb 3b                	jmp    80104b3f <fork+0x106>
    if(curproc->ofile[i])
80104b04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104b07:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b0a:	83 c2 08             	add    $0x8,%edx
80104b0d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b11:	85 c0                	test   %eax,%eax
80104b13:	74 26                	je     80104b3b <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104b15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104b18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104b1b:	83 c2 08             	add    $0x8,%edx
80104b1e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104b22:	83 ec 0c             	sub    $0xc,%esp
80104b25:	50                   	push   %eax
80104b26:	e8 7c c6 ff ff       	call   801011a7 <filedup>
80104b2b:	83 c4 10             	add    $0x10,%esp
80104b2e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104b31:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104b34:	83 c1 08             	add    $0x8,%ecx
80104b37:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104b3b:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104b3f:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104b43:	7e bf                	jle    80104b04 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
80104b45:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104b48:	8b 40 68             	mov    0x68(%eax),%eax
80104b4b:	83 ec 0c             	sub    $0xc,%esp
80104b4e:	50                   	push   %eax
80104b4f:	e8 ea cf ff ff       	call   80101b3e <idup>
80104b54:	83 c4 10             	add    $0x10,%esp
80104b57:	8b 55 d8             	mov    -0x28(%ebp),%edx
80104b5a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104b5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104b60:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b63:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104b66:	83 c0 6c             	add    $0x6c,%eax
80104b69:	83 ec 04             	sub    $0x4,%esp
80104b6c:	6a 10                	push   $0x10
80104b6e:	52                   	push   %edx
80104b6f:	50                   	push   %eax
80104b70:	e8 f4 0d 00 00       	call   80105969 <safestrcpy>
80104b75:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104b78:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104b7b:	8b 40 10             	mov    0x10(%eax),%eax
80104b7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

  acquire(&ptable.lock);
80104b81:	83 ec 0c             	sub    $0xc,%esp
80104b84:	68 c0 5d 11 80       	push   $0x80115dc0
80104b89:	e8 21 09 00 00       	call   801054af <acquire>
80104b8e:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < curproc->clock_size; i++){
80104b91:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80104b98:	eb 1e                	jmp    80104bb8 <fork+0x17f>
    np->clock_array[i] = curproc->clock_array[i];
80104b9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104b9d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104ba0:	83 c2 1c             	add    $0x1c,%edx
80104ba3:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80104ba7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104baa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80104bad:	83 c1 1c             	add    $0x1c,%ecx
80104bb0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
  for (int i = 0; i < curproc->clock_size; i++){
80104bb4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80104bb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104bbb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80104bc1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80104bc4:	7c d4                	jl     80104b9a <fork+0x161>

}

  np->state = RUNNABLE;
80104bc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104bc9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104bd0:	83 ec 0c             	sub    $0xc,%esp
80104bd3:	68 c0 5d 11 80       	push   $0x80115dc0
80104bd8:	e8 44 09 00 00       	call   80105521 <release>
80104bdd:	83 c4 10             	add    $0x10,%esp

  return pid;
80104be0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
80104be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104be6:	5b                   	pop    %ebx
80104be7:	5e                   	pop    %esi
80104be8:	5f                   	pop    %edi
80104be9:	5d                   	pop    %ebp
80104bea:	c3                   	ret    

80104beb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104beb:	f3 0f 1e fb          	endbr32 
80104bef:	55                   	push   %ebp
80104bf0:	89 e5                	mov    %esp,%ebp
80104bf2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104bf5:	e8 36 f9 ff ff       	call   80104530 <myproc>
80104bfa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104bfd:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80104c02:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104c05:	75 0d                	jne    80104c14 <exit+0x29>
    panic("init exiting");
80104c07:	83 ec 0c             	sub    $0xc,%esp
80104c0a:	68 42 9a 10 80       	push   $0x80109a42
80104c0f:	e8 f4 b9 ff ff       	call   80100608 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104c14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104c1b:	eb 3f                	jmp    80104c5c <exit+0x71>
    if(curproc->ofile[fd]){
80104c1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c20:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c23:	83 c2 08             	add    $0x8,%edx
80104c26:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c2a:	85 c0                	test   %eax,%eax
80104c2c:	74 2a                	je     80104c58 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
80104c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c34:	83 c2 08             	add    $0x8,%edx
80104c37:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104c3b:	83 ec 0c             	sub    $0xc,%esp
80104c3e:	50                   	push   %eax
80104c3f:	e8 b8 c5 ff ff       	call   801011fc <fileclose>
80104c44:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104c47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c4d:	83 c2 08             	add    $0x8,%edx
80104c50:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104c57:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104c58:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104c5c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104c60:	7e bb                	jle    80104c1d <exit+0x32>
    }
  }

  begin_op();
80104c62:	e8 0a eb ff ff       	call   80103771 <begin_op>
  iput(curproc->cwd);
80104c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c6a:	8b 40 68             	mov    0x68(%eax),%eax
80104c6d:	83 ec 0c             	sub    $0xc,%esp
80104c70:	50                   	push   %eax
80104c71:	e8 6f d0 ff ff       	call   80101ce5 <iput>
80104c76:	83 c4 10             	add    $0x10,%esp
  end_op();
80104c79:	e8 83 eb ff ff       	call   80103801 <end_op>
  curproc->cwd = 0;
80104c7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c81:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104c88:	83 ec 0c             	sub    $0xc,%esp
80104c8b:	68 c0 5d 11 80       	push   $0x80115dc0
80104c90:	e8 1a 08 00 00       	call   801054af <acquire>
80104c95:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104c98:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c9b:	8b 40 14             	mov    0x14(%eax),%eax
80104c9e:	83 ec 0c             	sub    $0xc,%esp
80104ca1:	50                   	push   %eax
80104ca2:	e8 41 04 00 00       	call   801050e8 <wakeup1>
80104ca7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104caa:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104cb1:	eb 3a                	jmp    80104ced <exit+0x102>
    if(p->parent == curproc){
80104cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb6:	8b 40 14             	mov    0x14(%eax),%eax
80104cb9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104cbc:	75 28                	jne    80104ce6 <exit+0xfb>
      p->parent = initproc;
80104cbe:	8b 15 40 d6 10 80    	mov    0x8010d640,%edx
80104cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc7:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccd:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd0:	83 f8 05             	cmp    $0x5,%eax
80104cd3:	75 11                	jne    80104ce6 <exit+0xfb>
        wakeup1(initproc);
80104cd5:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80104cda:	83 ec 0c             	sub    $0xc,%esp
80104cdd:	50                   	push   %eax
80104cde:	e8 05 04 00 00       	call   801050e8 <wakeup1>
80104ce3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ce6:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104ced:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104cf4:	72 bd                	jb     80104cb3 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104cf6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cf9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104d00:	e8 f3 01 00 00       	call   80104ef8 <sched>
  panic("zombie exit");
80104d05:	83 ec 0c             	sub    $0xc,%esp
80104d08:	68 4f 9a 10 80       	push   $0x80109a4f
80104d0d:	e8 f6 b8 ff ff       	call   80100608 <panic>

80104d12 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104d12:	f3 0f 1e fb          	endbr32 
80104d16:	55                   	push   %ebp
80104d17:	89 e5                	mov    %esp,%ebp
80104d19:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104d1c:	e8 0f f8 ff ff       	call   80104530 <myproc>
80104d21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104d24:	83 ec 0c             	sub    $0xc,%esp
80104d27:	68 c0 5d 11 80       	push   $0x80115dc0
80104d2c:	e8 7e 07 00 00       	call   801054af <acquire>
80104d31:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104d34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d3b:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104d42:	e9 a4 00 00 00       	jmp    80104deb <wait+0xd9>
      if(p->parent != curproc)
80104d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4a:	8b 40 14             	mov    0x14(%eax),%eax
80104d4d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104d50:	0f 85 8d 00 00 00    	jne    80104de3 <wait+0xd1>
        continue;
      havekids = 1;
80104d56:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d60:	8b 40 0c             	mov    0xc(%eax),%eax
80104d63:	83 f8 05             	cmp    $0x5,%eax
80104d66:	75 7c                	jne    80104de4 <wait+0xd2>
        // Found one.
        pid = p->pid;
80104d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6b:	8b 40 10             	mov    0x10(%eax),%eax
80104d6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d74:	8b 40 08             	mov    0x8(%eax),%eax
80104d77:	83 ec 0c             	sub    $0xc,%esp
80104d7a:	50                   	push   %eax
80104d7b:	e8 4e e0 ff ff       	call   80102dce <kfree>
80104d80:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d86:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d90:	8b 40 04             	mov    0x4(%eax),%eax
80104d93:	83 ec 0c             	sub    $0xc,%esp
80104d96:	50                   	push   %eax
80104d97:	e8 99 3a 00 00       	call   80108835 <freevm>
80104d9c:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104db3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104db6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbd:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104dce:	83 ec 0c             	sub    $0xc,%esp
80104dd1:	68 c0 5d 11 80       	push   $0x80115dc0
80104dd6:	e8 46 07 00 00       	call   80105521 <release>
80104ddb:	83 c4 10             	add    $0x10,%esp
        return pid;
80104dde:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104de1:	eb 54                	jmp    80104e37 <wait+0x125>
        continue;
80104de3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104de4:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104deb:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104df2:	0f 82 4f ff ff ff    	jb     80104d47 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104df8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104dfc:	74 0a                	je     80104e08 <wait+0xf6>
80104dfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e01:	8b 40 24             	mov    0x24(%eax),%eax
80104e04:	85 c0                	test   %eax,%eax
80104e06:	74 17                	je     80104e1f <wait+0x10d>
      release(&ptable.lock);
80104e08:	83 ec 0c             	sub    $0xc,%esp
80104e0b:	68 c0 5d 11 80       	push   $0x80115dc0
80104e10:	e8 0c 07 00 00       	call   80105521 <release>
80104e15:	83 c4 10             	add    $0x10,%esp
      return -1;
80104e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e1d:	eb 18                	jmp    80104e37 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104e1f:	83 ec 08             	sub    $0x8,%esp
80104e22:	68 c0 5d 11 80       	push   $0x80115dc0
80104e27:	ff 75 ec             	pushl  -0x14(%ebp)
80104e2a:	e8 0e 02 00 00       	call   8010503d <sleep>
80104e2f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104e32:	e9 fd fe ff ff       	jmp    80104d34 <wait+0x22>
  }
}
80104e37:	c9                   	leave  
80104e38:	c3                   	ret    

80104e39 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104e39:	f3 0f 1e fb          	endbr32 
80104e3d:	55                   	push   %ebp
80104e3e:	89 e5                	mov    %esp,%ebp
80104e40:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104e43:	e8 6c f6 ff ff       	call   801044b4 <mycpu>
80104e48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e4e:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104e55:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104e58:	e8 0f f6 ff ff       	call   8010446c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104e5d:	83 ec 0c             	sub    $0xc,%esp
80104e60:	68 c0 5d 11 80       	push   $0x80115dc0
80104e65:	e8 45 06 00 00       	call   801054af <acquire>
80104e6a:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e6d:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
80104e74:	eb 64                	jmp    80104eda <scheduler+0xa1>
      if(p->state != RUNNABLE)
80104e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e79:	8b 40 0c             	mov    0xc(%eax),%eax
80104e7c:	83 f8 03             	cmp    $0x3,%eax
80104e7f:	75 51                	jne    80104ed2 <scheduler+0x99>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e87:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104e8d:	83 ec 0c             	sub    $0xc,%esp
80104e90:	ff 75 f4             	pushl  -0xc(%ebp)
80104e93:	e8 e2 34 00 00       	call   8010837a <switchuvm>
80104e98:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104eab:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104eae:	83 c2 04             	add    $0x4,%edx
80104eb1:	83 ec 08             	sub    $0x8,%esp
80104eb4:	50                   	push   %eax
80104eb5:	52                   	push   %edx
80104eb6:	e8 27 0b 00 00       	call   801059e2 <swtch>
80104ebb:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104ebe:	e8 9a 34 00 00       	call   8010835d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104ec3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec6:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ecd:	00 00 00 
80104ed0:	eb 01                	jmp    80104ed3 <scheduler+0x9a>
        continue;
80104ed2:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed3:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
80104eda:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
80104ee1:	72 93                	jb     80104e76 <scheduler+0x3d>
    }
    release(&ptable.lock);
80104ee3:	83 ec 0c             	sub    $0xc,%esp
80104ee6:	68 c0 5d 11 80       	push   $0x80115dc0
80104eeb:	e8 31 06 00 00       	call   80105521 <release>
80104ef0:	83 c4 10             	add    $0x10,%esp
    sti();
80104ef3:	e9 60 ff ff ff       	jmp    80104e58 <scheduler+0x1f>

80104ef8 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ef8:	f3 0f 1e fb          	endbr32 
80104efc:	55                   	push   %ebp
80104efd:	89 e5                	mov    %esp,%ebp
80104eff:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104f02:	e8 29 f6 ff ff       	call   80104530 <myproc>
80104f07:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104f0a:	83 ec 0c             	sub    $0xc,%esp
80104f0d:	68 c0 5d 11 80       	push   $0x80115dc0
80104f12:	e8 df 06 00 00       	call   801055f6 <holding>
80104f17:	83 c4 10             	add    $0x10,%esp
80104f1a:	85 c0                	test   %eax,%eax
80104f1c:	75 0d                	jne    80104f2b <sched+0x33>
    panic("sched ptable.lock");
80104f1e:	83 ec 0c             	sub    $0xc,%esp
80104f21:	68 5b 9a 10 80       	push   $0x80109a5b
80104f26:	e8 dd b6 ff ff       	call   80100608 <panic>
  if(mycpu()->ncli != 1)
80104f2b:	e8 84 f5 ff ff       	call   801044b4 <mycpu>
80104f30:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f36:	83 f8 01             	cmp    $0x1,%eax
80104f39:	74 0d                	je     80104f48 <sched+0x50>
    panic("sched locks");
80104f3b:	83 ec 0c             	sub    $0xc,%esp
80104f3e:	68 6d 9a 10 80       	push   $0x80109a6d
80104f43:	e8 c0 b6 ff ff       	call   80100608 <panic>
  if(p->state == RUNNING)
80104f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4b:	8b 40 0c             	mov    0xc(%eax),%eax
80104f4e:	83 f8 04             	cmp    $0x4,%eax
80104f51:	75 0d                	jne    80104f60 <sched+0x68>
    panic("sched running");
80104f53:	83 ec 0c             	sub    $0xc,%esp
80104f56:	68 79 9a 10 80       	push   $0x80109a79
80104f5b:	e8 a8 b6 ff ff       	call   80100608 <panic>
  if(readeflags()&FL_IF)
80104f60:	e8 f7 f4 ff ff       	call   8010445c <readeflags>
80104f65:	25 00 02 00 00       	and    $0x200,%eax
80104f6a:	85 c0                	test   %eax,%eax
80104f6c:	74 0d                	je     80104f7b <sched+0x83>
    panic("sched interruptible");
80104f6e:	83 ec 0c             	sub    $0xc,%esp
80104f71:	68 87 9a 10 80       	push   $0x80109a87
80104f76:	e8 8d b6 ff ff       	call   80100608 <panic>
  intena = mycpu()->intena;
80104f7b:	e8 34 f5 ff ff       	call   801044b4 <mycpu>
80104f80:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104f89:	e8 26 f5 ff ff       	call   801044b4 <mycpu>
80104f8e:	8b 40 04             	mov    0x4(%eax),%eax
80104f91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f94:	83 c2 1c             	add    $0x1c,%edx
80104f97:	83 ec 08             	sub    $0x8,%esp
80104f9a:	50                   	push   %eax
80104f9b:	52                   	push   %edx
80104f9c:	e8 41 0a 00 00       	call   801059e2 <swtch>
80104fa1:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104fa4:	e8 0b f5 ff ff       	call   801044b4 <mycpu>
80104fa9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104fac:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104fb2:	90                   	nop
80104fb3:	c9                   	leave  
80104fb4:	c3                   	ret    

80104fb5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104fb5:	f3 0f 1e fb          	endbr32 
80104fb9:	55                   	push   %ebp
80104fba:	89 e5                	mov    %esp,%ebp
80104fbc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104fbf:	83 ec 0c             	sub    $0xc,%esp
80104fc2:	68 c0 5d 11 80       	push   $0x80115dc0
80104fc7:	e8 e3 04 00 00       	call   801054af <acquire>
80104fcc:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104fcf:	e8 5c f5 ff ff       	call   80104530 <myproc>
80104fd4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104fdb:	e8 18 ff ff ff       	call   80104ef8 <sched>
  release(&ptable.lock);
80104fe0:	83 ec 0c             	sub    $0xc,%esp
80104fe3:	68 c0 5d 11 80       	push   $0x80115dc0
80104fe8:	e8 34 05 00 00       	call   80105521 <release>
80104fed:	83 c4 10             	add    $0x10,%esp
}
80104ff0:	90                   	nop
80104ff1:	c9                   	leave  
80104ff2:	c3                   	ret    

80104ff3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ff3:	f3 0f 1e fb          	endbr32 
80104ff7:	55                   	push   %ebp
80104ff8:	89 e5                	mov    %esp,%ebp
80104ffa:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ffd:	83 ec 0c             	sub    $0xc,%esp
80105000:	68 c0 5d 11 80       	push   $0x80115dc0
80105005:	e8 17 05 00 00       	call   80105521 <release>
8010500a:	83 c4 10             	add    $0x10,%esp

  if (first) {
8010500d:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80105012:	85 c0                	test   %eax,%eax
80105014:	74 24                	je     8010503a <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80105016:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
8010501d:	00 00 00 
    iinit(ROOTDEV);
80105020:	83 ec 0c             	sub    $0xc,%esp
80105023:	6a 01                	push   $0x1
80105025:	e8 cc c7 ff ff       	call   801017f6 <iinit>
8010502a:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
8010502d:	83 ec 0c             	sub    $0xc,%esp
80105030:	6a 01                	push   $0x1
80105032:	e8 07 e5 ff ff       	call   8010353e <initlog>
80105037:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010503a:	90                   	nop
8010503b:	c9                   	leave  
8010503c:	c3                   	ret    

8010503d <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010503d:	f3 0f 1e fb          	endbr32 
80105041:	55                   	push   %ebp
80105042:	89 e5                	mov    %esp,%ebp
80105044:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80105047:	e8 e4 f4 ff ff       	call   80104530 <myproc>
8010504c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010504f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105053:	75 0d                	jne    80105062 <sleep+0x25>
    panic("sleep");
80105055:	83 ec 0c             	sub    $0xc,%esp
80105058:	68 9b 9a 10 80       	push   $0x80109a9b
8010505d:	e8 a6 b5 ff ff       	call   80100608 <panic>

  if(lk == 0)
80105062:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105066:	75 0d                	jne    80105075 <sleep+0x38>
    panic("sleep without lk");
80105068:	83 ec 0c             	sub    $0xc,%esp
8010506b:	68 a1 9a 10 80       	push   $0x80109aa1
80105070:	e8 93 b5 ff ff       	call   80100608 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105075:	81 7d 0c c0 5d 11 80 	cmpl   $0x80115dc0,0xc(%ebp)
8010507c:	74 1e                	je     8010509c <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010507e:	83 ec 0c             	sub    $0xc,%esp
80105081:	68 c0 5d 11 80       	push   $0x80115dc0
80105086:	e8 24 04 00 00       	call   801054af <acquire>
8010508b:	83 c4 10             	add    $0x10,%esp
    release(lk);
8010508e:	83 ec 0c             	sub    $0xc,%esp
80105091:	ff 75 0c             	pushl  0xc(%ebp)
80105094:	e8 88 04 00 00       	call   80105521 <release>
80105099:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010509c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509f:	8b 55 08             	mov    0x8(%ebp),%edx
801050a2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801050a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050a8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
801050af:	e8 44 fe ff ff       	call   80104ef8 <sched>

  // Tidy up.
  p->chan = 0;
801050b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
801050be:	81 7d 0c c0 5d 11 80 	cmpl   $0x80115dc0,0xc(%ebp)
801050c5:	74 1e                	je     801050e5 <sleep+0xa8>
    release(&ptable.lock);
801050c7:	83 ec 0c             	sub    $0xc,%esp
801050ca:	68 c0 5d 11 80       	push   $0x80115dc0
801050cf:	e8 4d 04 00 00       	call   80105521 <release>
801050d4:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
801050d7:	83 ec 0c             	sub    $0xc,%esp
801050da:	ff 75 0c             	pushl  0xc(%ebp)
801050dd:	e8 cd 03 00 00       	call   801054af <acquire>
801050e2:	83 c4 10             	add    $0x10,%esp
  }
}
801050e5:	90                   	nop
801050e6:	c9                   	leave  
801050e7:	c3                   	ret    

801050e8 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801050e8:	f3 0f 1e fb          	endbr32 
801050ec:	55                   	push   %ebp
801050ed:	89 e5                	mov    %esp,%ebp
801050ef:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801050f2:	c7 45 fc f4 5d 11 80 	movl   $0x80115df4,-0x4(%ebp)
801050f9:	eb 27                	jmp    80105122 <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
801050fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050fe:	8b 40 0c             	mov    0xc(%eax),%eax
80105101:	83 f8 02             	cmp    $0x2,%eax
80105104:	75 15                	jne    8010511b <wakeup1+0x33>
80105106:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105109:	8b 40 20             	mov    0x20(%eax),%eax
8010510c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010510f:	75 0a                	jne    8010511b <wakeup1+0x33>
      p->state = RUNNABLE;
80105111:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105114:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010511b:	81 45 fc a4 00 00 00 	addl   $0xa4,-0x4(%ebp)
80105122:	81 7d fc f4 86 11 80 	cmpl   $0x801186f4,-0x4(%ebp)
80105129:	72 d0                	jb     801050fb <wakeup1+0x13>
}
8010512b:	90                   	nop
8010512c:	90                   	nop
8010512d:	c9                   	leave  
8010512e:	c3                   	ret    

8010512f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010512f:	f3 0f 1e fb          	endbr32 
80105133:	55                   	push   %ebp
80105134:	89 e5                	mov    %esp,%ebp
80105136:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105139:	83 ec 0c             	sub    $0xc,%esp
8010513c:	68 c0 5d 11 80       	push   $0x80115dc0
80105141:	e8 69 03 00 00       	call   801054af <acquire>
80105146:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105149:	83 ec 0c             	sub    $0xc,%esp
8010514c:	ff 75 08             	pushl  0x8(%ebp)
8010514f:	e8 94 ff ff ff       	call   801050e8 <wakeup1>
80105154:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105157:	83 ec 0c             	sub    $0xc,%esp
8010515a:	68 c0 5d 11 80       	push   $0x80115dc0
8010515f:	e8 bd 03 00 00       	call   80105521 <release>
80105164:	83 c4 10             	add    $0x10,%esp
}
80105167:	90                   	nop
80105168:	c9                   	leave  
80105169:	c3                   	ret    

8010516a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010516a:	f3 0f 1e fb          	endbr32 
8010516e:	55                   	push   %ebp
8010516f:	89 e5                	mov    %esp,%ebp
80105171:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105174:	83 ec 0c             	sub    $0xc,%esp
80105177:	68 c0 5d 11 80       	push   $0x80115dc0
8010517c:	e8 2e 03 00 00       	call   801054af <acquire>
80105181:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105184:	c7 45 f4 f4 5d 11 80 	movl   $0x80115df4,-0xc(%ebp)
8010518b:	eb 48                	jmp    801051d5 <kill+0x6b>
    if(p->pid == pid){
8010518d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105190:	8b 40 10             	mov    0x10(%eax),%eax
80105193:	39 45 08             	cmp    %eax,0x8(%ebp)
80105196:	75 36                	jne    801051ce <kill+0x64>
      p->killed = 1;
80105198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010519b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801051a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a5:	8b 40 0c             	mov    0xc(%eax),%eax
801051a8:	83 f8 02             	cmp    $0x2,%eax
801051ab:	75 0a                	jne    801051b7 <kill+0x4d>
        p->state = RUNNABLE;
801051ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801051b7:	83 ec 0c             	sub    $0xc,%esp
801051ba:	68 c0 5d 11 80       	push   $0x80115dc0
801051bf:	e8 5d 03 00 00       	call   80105521 <release>
801051c4:	83 c4 10             	add    $0x10,%esp
      return 0;
801051c7:	b8 00 00 00 00       	mov    $0x0,%eax
801051cc:	eb 25                	jmp    801051f3 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051ce:	81 45 f4 a4 00 00 00 	addl   $0xa4,-0xc(%ebp)
801051d5:	81 7d f4 f4 86 11 80 	cmpl   $0x801186f4,-0xc(%ebp)
801051dc:	72 af                	jb     8010518d <kill+0x23>
    }
  }
  release(&ptable.lock);
801051de:	83 ec 0c             	sub    $0xc,%esp
801051e1:	68 c0 5d 11 80       	push   $0x80115dc0
801051e6:	e8 36 03 00 00       	call   80105521 <release>
801051eb:	83 c4 10             	add    $0x10,%esp
  return -1;
801051ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801051f3:	c9                   	leave  
801051f4:	c3                   	ret    

801051f5 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801051f5:	f3 0f 1e fb          	endbr32 
801051f9:	55                   	push   %ebp
801051fa:	89 e5                	mov    %esp,%ebp
801051fc:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051ff:	c7 45 f0 f4 5d 11 80 	movl   $0x80115df4,-0x10(%ebp)
80105206:	e9 da 00 00 00       	jmp    801052e5 <procdump+0xf0>
    if(p->state == UNUSED)
8010520b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010520e:	8b 40 0c             	mov    0xc(%eax),%eax
80105211:	85 c0                	test   %eax,%eax
80105213:	0f 84 c4 00 00 00    	je     801052dd <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105219:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521c:	8b 40 0c             	mov    0xc(%eax),%eax
8010521f:	83 f8 05             	cmp    $0x5,%eax
80105222:	77 23                	ja     80105247 <procdump+0x52>
80105224:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105227:	8b 40 0c             	mov    0xc(%eax),%eax
8010522a:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105231:	85 c0                	test   %eax,%eax
80105233:	74 12                	je     80105247 <procdump+0x52>
      state = states[p->state];
80105235:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105238:	8b 40 0c             	mov    0xc(%eax),%eax
8010523b:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80105242:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105245:	eb 07                	jmp    8010524e <procdump+0x59>
    else
      state = "???";
80105247:	c7 45 ec b2 9a 10 80 	movl   $0x80109ab2,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
8010524e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105251:	8d 50 6c             	lea    0x6c(%eax),%edx
80105254:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105257:	8b 40 10             	mov    0x10(%eax),%eax
8010525a:	52                   	push   %edx
8010525b:	ff 75 ec             	pushl  -0x14(%ebp)
8010525e:	50                   	push   %eax
8010525f:	68 b6 9a 10 80       	push   $0x80109ab6
80105264:	e8 af b1 ff ff       	call   80100418 <cprintf>
80105269:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010526c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010526f:	8b 40 0c             	mov    0xc(%eax),%eax
80105272:	83 f8 02             	cmp    $0x2,%eax
80105275:	75 54                	jne    801052cb <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105277:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010527d:	8b 40 0c             	mov    0xc(%eax),%eax
80105280:	83 c0 08             	add    $0x8,%eax
80105283:	89 c2                	mov    %eax,%edx
80105285:	83 ec 08             	sub    $0x8,%esp
80105288:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010528b:	50                   	push   %eax
8010528c:	52                   	push   %edx
8010528d:	e8 e5 02 00 00       	call   80105577 <getcallerpcs>
80105292:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105295:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010529c:	eb 1c                	jmp    801052ba <procdump+0xc5>
        cprintf(" %p", pc[i]);
8010529e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052a1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052a5:	83 ec 08             	sub    $0x8,%esp
801052a8:	50                   	push   %eax
801052a9:	68 bf 9a 10 80       	push   $0x80109abf
801052ae:	e8 65 b1 ff ff       	call   80100418 <cprintf>
801052b3:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801052b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801052ba:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801052be:	7f 0b                	jg     801052cb <procdump+0xd6>
801052c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052c7:	85 c0                	test   %eax,%eax
801052c9:	75 d3                	jne    8010529e <procdump+0xa9>
    }
    cprintf("\n");
801052cb:	83 ec 0c             	sub    $0xc,%esp
801052ce:	68 c3 9a 10 80       	push   $0x80109ac3
801052d3:	e8 40 b1 ff ff       	call   80100418 <cprintf>
801052d8:	83 c4 10             	add    $0x10,%esp
801052db:	eb 01                	jmp    801052de <procdump+0xe9>
      continue;
801052dd:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052de:	81 45 f0 a4 00 00 00 	addl   $0xa4,-0x10(%ebp)
801052e5:	81 7d f0 f4 86 11 80 	cmpl   $0x801186f4,-0x10(%ebp)
801052ec:	0f 82 19 ff ff ff    	jb     8010520b <procdump+0x16>
  }
}
801052f2:	90                   	nop
801052f3:	90                   	nop
801052f4:	c9                   	leave  
801052f5:	c3                   	ret    

801052f6 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801052f6:	f3 0f 1e fb          	endbr32 
801052fa:	55                   	push   %ebp
801052fb:	89 e5                	mov    %esp,%ebp
801052fd:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80105300:	8b 45 08             	mov    0x8(%ebp),%eax
80105303:	83 c0 04             	add    $0x4,%eax
80105306:	83 ec 08             	sub    $0x8,%esp
80105309:	68 ef 9a 10 80       	push   $0x80109aef
8010530e:	50                   	push   %eax
8010530f:	e8 75 01 00 00       	call   80105489 <initlock>
80105314:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
80105317:	8b 45 08             	mov    0x8(%ebp),%eax
8010531a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010531d:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105320:	8b 45 08             	mov    0x8(%ebp),%eax
80105323:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
8010532c:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105333:	90                   	nop
80105334:	c9                   	leave  
80105335:	c3                   	ret    

80105336 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105336:	f3 0f 1e fb          	endbr32 
8010533a:	55                   	push   %ebp
8010533b:	89 e5                	mov    %esp,%ebp
8010533d:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105340:	8b 45 08             	mov    0x8(%ebp),%eax
80105343:	83 c0 04             	add    $0x4,%eax
80105346:	83 ec 0c             	sub    $0xc,%esp
80105349:	50                   	push   %eax
8010534a:	e8 60 01 00 00       	call   801054af <acquire>
8010534f:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105352:	eb 15                	jmp    80105369 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
80105354:	8b 45 08             	mov    0x8(%ebp),%eax
80105357:	83 c0 04             	add    $0x4,%eax
8010535a:	83 ec 08             	sub    $0x8,%esp
8010535d:	50                   	push   %eax
8010535e:	ff 75 08             	pushl  0x8(%ebp)
80105361:	e8 d7 fc ff ff       	call   8010503d <sleep>
80105366:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105369:	8b 45 08             	mov    0x8(%ebp),%eax
8010536c:	8b 00                	mov    (%eax),%eax
8010536e:	85 c0                	test   %eax,%eax
80105370:	75 e2                	jne    80105354 <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105372:	8b 45 08             	mov    0x8(%ebp),%eax
80105375:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010537b:	e8 b0 f1 ff ff       	call   80104530 <myproc>
80105380:	8b 50 10             	mov    0x10(%eax),%edx
80105383:	8b 45 08             	mov    0x8(%ebp),%eax
80105386:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105389:	8b 45 08             	mov    0x8(%ebp),%eax
8010538c:	83 c0 04             	add    $0x4,%eax
8010538f:	83 ec 0c             	sub    $0xc,%esp
80105392:	50                   	push   %eax
80105393:	e8 89 01 00 00       	call   80105521 <release>
80105398:	83 c4 10             	add    $0x10,%esp
}
8010539b:	90                   	nop
8010539c:	c9                   	leave  
8010539d:	c3                   	ret    

8010539e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010539e:	f3 0f 1e fb          	endbr32 
801053a2:	55                   	push   %ebp
801053a3:	89 e5                	mov    %esp,%ebp
801053a5:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801053a8:	8b 45 08             	mov    0x8(%ebp),%eax
801053ab:	83 c0 04             	add    $0x4,%eax
801053ae:	83 ec 0c             	sub    $0xc,%esp
801053b1:	50                   	push   %eax
801053b2:	e8 f8 00 00 00       	call   801054af <acquire>
801053b7:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801053ba:	8b 45 08             	mov    0x8(%ebp),%eax
801053bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801053c3:	8b 45 08             	mov    0x8(%ebp),%eax
801053c6:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801053cd:	83 ec 0c             	sub    $0xc,%esp
801053d0:	ff 75 08             	pushl  0x8(%ebp)
801053d3:	e8 57 fd ff ff       	call   8010512f <wakeup>
801053d8:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801053db:	8b 45 08             	mov    0x8(%ebp),%eax
801053de:	83 c0 04             	add    $0x4,%eax
801053e1:	83 ec 0c             	sub    $0xc,%esp
801053e4:	50                   	push   %eax
801053e5:	e8 37 01 00 00       	call   80105521 <release>
801053ea:	83 c4 10             	add    $0x10,%esp
}
801053ed:	90                   	nop
801053ee:	c9                   	leave  
801053ef:	c3                   	ret    

801053f0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801053f0:	f3 0f 1e fb          	endbr32 
801053f4:	55                   	push   %ebp
801053f5:	89 e5                	mov    %esp,%ebp
801053f7:	53                   	push   %ebx
801053f8:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801053fb:	8b 45 08             	mov    0x8(%ebp),%eax
801053fe:	83 c0 04             	add    $0x4,%eax
80105401:	83 ec 0c             	sub    $0xc,%esp
80105404:	50                   	push   %eax
80105405:	e8 a5 00 00 00       	call   801054af <acquire>
8010540a:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
8010540d:	8b 45 08             	mov    0x8(%ebp),%eax
80105410:	8b 00                	mov    (%eax),%eax
80105412:	85 c0                	test   %eax,%eax
80105414:	74 19                	je     8010542f <holdingsleep+0x3f>
80105416:	8b 45 08             	mov    0x8(%ebp),%eax
80105419:	8b 58 3c             	mov    0x3c(%eax),%ebx
8010541c:	e8 0f f1 ff ff       	call   80104530 <myproc>
80105421:	8b 40 10             	mov    0x10(%eax),%eax
80105424:	39 c3                	cmp    %eax,%ebx
80105426:	75 07                	jne    8010542f <holdingsleep+0x3f>
80105428:	b8 01 00 00 00       	mov    $0x1,%eax
8010542d:	eb 05                	jmp    80105434 <holdingsleep+0x44>
8010542f:	b8 00 00 00 00       	mov    $0x0,%eax
80105434:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105437:	8b 45 08             	mov    0x8(%ebp),%eax
8010543a:	83 c0 04             	add    $0x4,%eax
8010543d:	83 ec 0c             	sub    $0xc,%esp
80105440:	50                   	push   %eax
80105441:	e8 db 00 00 00       	call   80105521 <release>
80105446:	83 c4 10             	add    $0x10,%esp
  return r;
80105449:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010544c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010544f:	c9                   	leave  
80105450:	c3                   	ret    

80105451 <readeflags>:
{
80105451:	55                   	push   %ebp
80105452:	89 e5                	mov    %esp,%ebp
80105454:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105457:	9c                   	pushf  
80105458:	58                   	pop    %eax
80105459:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010545c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010545f:	c9                   	leave  
80105460:	c3                   	ret    

80105461 <cli>:
{
80105461:	55                   	push   %ebp
80105462:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105464:	fa                   	cli    
}
80105465:	90                   	nop
80105466:	5d                   	pop    %ebp
80105467:	c3                   	ret    

80105468 <sti>:
{
80105468:	55                   	push   %ebp
80105469:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010546b:	fb                   	sti    
}
8010546c:	90                   	nop
8010546d:	5d                   	pop    %ebp
8010546e:	c3                   	ret    

8010546f <xchg>:
{
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105475:	8b 55 08             	mov    0x8(%ebp),%edx
80105478:	8b 45 0c             	mov    0xc(%ebp),%eax
8010547b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010547e:	f0 87 02             	lock xchg %eax,(%edx)
80105481:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105484:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105487:	c9                   	leave  
80105488:	c3                   	ret    

80105489 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105489:	f3 0f 1e fb          	endbr32 
8010548d:	55                   	push   %ebp
8010548e:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105490:	8b 45 08             	mov    0x8(%ebp),%eax
80105493:	8b 55 0c             	mov    0xc(%ebp),%edx
80105496:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105499:	8b 45 08             	mov    0x8(%ebp),%eax
8010549c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801054a2:	8b 45 08             	mov    0x8(%ebp),%eax
801054a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801054ac:	90                   	nop
801054ad:	5d                   	pop    %ebp
801054ae:	c3                   	ret    

801054af <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801054af:	f3 0f 1e fb          	endbr32 
801054b3:	55                   	push   %ebp
801054b4:	89 e5                	mov    %esp,%ebp
801054b6:	53                   	push   %ebx
801054b7:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801054ba:	e8 7c 01 00 00       	call   8010563b <pushcli>
  if(holding(lk))
801054bf:	8b 45 08             	mov    0x8(%ebp),%eax
801054c2:	83 ec 0c             	sub    $0xc,%esp
801054c5:	50                   	push   %eax
801054c6:	e8 2b 01 00 00       	call   801055f6 <holding>
801054cb:	83 c4 10             	add    $0x10,%esp
801054ce:	85 c0                	test   %eax,%eax
801054d0:	74 0d                	je     801054df <acquire+0x30>
    panic("acquire");
801054d2:	83 ec 0c             	sub    $0xc,%esp
801054d5:	68 fa 9a 10 80       	push   $0x80109afa
801054da:	e8 29 b1 ff ff       	call   80100608 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801054df:	90                   	nop
801054e0:	8b 45 08             	mov    0x8(%ebp),%eax
801054e3:	83 ec 08             	sub    $0x8,%esp
801054e6:	6a 01                	push   $0x1
801054e8:	50                   	push   %eax
801054e9:	e8 81 ff ff ff       	call   8010546f <xchg>
801054ee:	83 c4 10             	add    $0x10,%esp
801054f1:	85 c0                	test   %eax,%eax
801054f3:	75 eb                	jne    801054e0 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801054f5:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801054fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
801054fd:	e8 b2 ef ff ff       	call   801044b4 <mycpu>
80105502:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105505:	8b 45 08             	mov    0x8(%ebp),%eax
80105508:	83 c0 0c             	add    $0xc,%eax
8010550b:	83 ec 08             	sub    $0x8,%esp
8010550e:	50                   	push   %eax
8010550f:	8d 45 08             	lea    0x8(%ebp),%eax
80105512:	50                   	push   %eax
80105513:	e8 5f 00 00 00       	call   80105577 <getcallerpcs>
80105518:	83 c4 10             	add    $0x10,%esp
}
8010551b:	90                   	nop
8010551c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010551f:	c9                   	leave  
80105520:	c3                   	ret    

80105521 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105521:	f3 0f 1e fb          	endbr32 
80105525:	55                   	push   %ebp
80105526:	89 e5                	mov    %esp,%ebp
80105528:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010552b:	83 ec 0c             	sub    $0xc,%esp
8010552e:	ff 75 08             	pushl  0x8(%ebp)
80105531:	e8 c0 00 00 00       	call   801055f6 <holding>
80105536:	83 c4 10             	add    $0x10,%esp
80105539:	85 c0                	test   %eax,%eax
8010553b:	75 0d                	jne    8010554a <release+0x29>
    panic("release");
8010553d:	83 ec 0c             	sub    $0xc,%esp
80105540:	68 02 9b 10 80       	push   $0x80109b02
80105545:	e8 be b0 ff ff       	call   80100608 <panic>

  lk->pcs[0] = 0;
8010554a:	8b 45 08             	mov    0x8(%ebp),%eax
8010554d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105554:	8b 45 08             	mov    0x8(%ebp),%eax
80105557:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010555e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105563:	8b 45 08             	mov    0x8(%ebp),%eax
80105566:	8b 55 08             	mov    0x8(%ebp),%edx
80105569:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010556f:	e8 18 01 00 00       	call   8010568c <popcli>
}
80105574:	90                   	nop
80105575:	c9                   	leave  
80105576:	c3                   	ret    

80105577 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105577:	f3 0f 1e fb          	endbr32 
8010557b:	55                   	push   %ebp
8010557c:	89 e5                	mov    %esp,%ebp
8010557e:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105581:	8b 45 08             	mov    0x8(%ebp),%eax
80105584:	83 e8 08             	sub    $0x8,%eax
80105587:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010558a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105591:	eb 38                	jmp    801055cb <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105593:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105597:	74 53                	je     801055ec <getcallerpcs+0x75>
80105599:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801055a0:	76 4a                	jbe    801055ec <getcallerpcs+0x75>
801055a2:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801055a6:	74 44                	je     801055ec <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
801055a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b5:	01 c2                	add    %eax,%edx
801055b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ba:	8b 40 04             	mov    0x4(%eax),%eax
801055bd:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801055bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c2:	8b 00                	mov    (%eax),%eax
801055c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801055c7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801055cb:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055cf:	7e c2                	jle    80105593 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801055d1:	eb 19                	jmp    801055ec <getcallerpcs+0x75>
    pcs[i] = 0;
801055d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e0:	01 d0                	add    %edx,%eax
801055e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801055e8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801055ec:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055f0:	7e e1                	jle    801055d3 <getcallerpcs+0x5c>
}
801055f2:	90                   	nop
801055f3:	90                   	nop
801055f4:	c9                   	leave  
801055f5:	c3                   	ret    

801055f6 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801055f6:	f3 0f 1e fb          	endbr32 
801055fa:	55                   	push   %ebp
801055fb:	89 e5                	mov    %esp,%ebp
801055fd:	53                   	push   %ebx
801055fe:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
80105601:	e8 35 00 00 00       	call   8010563b <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	8b 00                	mov    (%eax),%eax
8010560b:	85 c0                	test   %eax,%eax
8010560d:	74 16                	je     80105625 <holding+0x2f>
8010560f:	8b 45 08             	mov    0x8(%ebp),%eax
80105612:	8b 58 08             	mov    0x8(%eax),%ebx
80105615:	e8 9a ee ff ff       	call   801044b4 <mycpu>
8010561a:	39 c3                	cmp    %eax,%ebx
8010561c:	75 07                	jne    80105625 <holding+0x2f>
8010561e:	b8 01 00 00 00       	mov    $0x1,%eax
80105623:	eb 05                	jmp    8010562a <holding+0x34>
80105625:	b8 00 00 00 00       	mov    $0x0,%eax
8010562a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
8010562d:	e8 5a 00 00 00       	call   8010568c <popcli>
  return r;
80105632:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105635:	83 c4 14             	add    $0x14,%esp
80105638:	5b                   	pop    %ebx
80105639:	5d                   	pop    %ebp
8010563a:	c3                   	ret    

8010563b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010563b:	f3 0f 1e fb          	endbr32 
8010563f:	55                   	push   %ebp
80105640:	89 e5                	mov    %esp,%ebp
80105642:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105645:	e8 07 fe ff ff       	call   80105451 <readeflags>
8010564a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010564d:	e8 0f fe ff ff       	call   80105461 <cli>
  if(mycpu()->ncli == 0)
80105652:	e8 5d ee ff ff       	call   801044b4 <mycpu>
80105657:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010565d:	85 c0                	test   %eax,%eax
8010565f:	75 14                	jne    80105675 <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105661:	e8 4e ee ff ff       	call   801044b4 <mycpu>
80105666:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105669:	81 e2 00 02 00 00    	and    $0x200,%edx
8010566f:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105675:	e8 3a ee ff ff       	call   801044b4 <mycpu>
8010567a:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105680:	83 c2 01             	add    $0x1,%edx
80105683:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105689:	90                   	nop
8010568a:	c9                   	leave  
8010568b:	c3                   	ret    

8010568c <popcli>:

void
popcli(void)
{
8010568c:	f3 0f 1e fb          	endbr32 
80105690:	55                   	push   %ebp
80105691:	89 e5                	mov    %esp,%ebp
80105693:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105696:	e8 b6 fd ff ff       	call   80105451 <readeflags>
8010569b:	25 00 02 00 00       	and    $0x200,%eax
801056a0:	85 c0                	test   %eax,%eax
801056a2:	74 0d                	je     801056b1 <popcli+0x25>
    panic("popcli - interruptible");
801056a4:	83 ec 0c             	sub    $0xc,%esp
801056a7:	68 0a 9b 10 80       	push   $0x80109b0a
801056ac:	e8 57 af ff ff       	call   80100608 <panic>
  if(--mycpu()->ncli < 0)
801056b1:	e8 fe ed ff ff       	call   801044b4 <mycpu>
801056b6:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801056bc:	83 ea 01             	sub    $0x1,%edx
801056bf:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801056c5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056cb:	85 c0                	test   %eax,%eax
801056cd:	79 0d                	jns    801056dc <popcli+0x50>
    panic("popcli");
801056cf:	83 ec 0c             	sub    $0xc,%esp
801056d2:	68 21 9b 10 80       	push   $0x80109b21
801056d7:	e8 2c af ff ff       	call   80100608 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801056dc:	e8 d3 ed ff ff       	call   801044b4 <mycpu>
801056e1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056e7:	85 c0                	test   %eax,%eax
801056e9:	75 14                	jne    801056ff <popcli+0x73>
801056eb:	e8 c4 ed ff ff       	call   801044b4 <mycpu>
801056f0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801056f6:	85 c0                	test   %eax,%eax
801056f8:	74 05                	je     801056ff <popcli+0x73>
    sti();
801056fa:	e8 69 fd ff ff       	call   80105468 <sti>
}
801056ff:	90                   	nop
80105700:	c9                   	leave  
80105701:	c3                   	ret    

80105702 <stosb>:
{
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
80105705:	57                   	push   %edi
80105706:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105707:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010570a:	8b 55 10             	mov    0x10(%ebp),%edx
8010570d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105710:	89 cb                	mov    %ecx,%ebx
80105712:	89 df                	mov    %ebx,%edi
80105714:	89 d1                	mov    %edx,%ecx
80105716:	fc                   	cld    
80105717:	f3 aa                	rep stos %al,%es:(%edi)
80105719:	89 ca                	mov    %ecx,%edx
8010571b:	89 fb                	mov    %edi,%ebx
8010571d:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105720:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105723:	90                   	nop
80105724:	5b                   	pop    %ebx
80105725:	5f                   	pop    %edi
80105726:	5d                   	pop    %ebp
80105727:	c3                   	ret    

80105728 <stosl>:
{
80105728:	55                   	push   %ebp
80105729:	89 e5                	mov    %esp,%ebp
8010572b:	57                   	push   %edi
8010572c:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010572d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105730:	8b 55 10             	mov    0x10(%ebp),%edx
80105733:	8b 45 0c             	mov    0xc(%ebp),%eax
80105736:	89 cb                	mov    %ecx,%ebx
80105738:	89 df                	mov    %ebx,%edi
8010573a:	89 d1                	mov    %edx,%ecx
8010573c:	fc                   	cld    
8010573d:	f3 ab                	rep stos %eax,%es:(%edi)
8010573f:	89 ca                	mov    %ecx,%edx
80105741:	89 fb                	mov    %edi,%ebx
80105743:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105746:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105749:	90                   	nop
8010574a:	5b                   	pop    %ebx
8010574b:	5f                   	pop    %edi
8010574c:	5d                   	pop    %ebp
8010574d:	c3                   	ret    

8010574e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010574e:	f3 0f 1e fb          	endbr32 
80105752:	55                   	push   %ebp
80105753:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105755:	8b 45 08             	mov    0x8(%ebp),%eax
80105758:	83 e0 03             	and    $0x3,%eax
8010575b:	85 c0                	test   %eax,%eax
8010575d:	75 43                	jne    801057a2 <memset+0x54>
8010575f:	8b 45 10             	mov    0x10(%ebp),%eax
80105762:	83 e0 03             	and    $0x3,%eax
80105765:	85 c0                	test   %eax,%eax
80105767:	75 39                	jne    801057a2 <memset+0x54>
    c &= 0xFF;
80105769:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105770:	8b 45 10             	mov    0x10(%ebp),%eax
80105773:	c1 e8 02             	shr    $0x2,%eax
80105776:	89 c1                	mov    %eax,%ecx
80105778:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577b:	c1 e0 18             	shl    $0x18,%eax
8010577e:	89 c2                	mov    %eax,%edx
80105780:	8b 45 0c             	mov    0xc(%ebp),%eax
80105783:	c1 e0 10             	shl    $0x10,%eax
80105786:	09 c2                	or     %eax,%edx
80105788:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578b:	c1 e0 08             	shl    $0x8,%eax
8010578e:	09 d0                	or     %edx,%eax
80105790:	0b 45 0c             	or     0xc(%ebp),%eax
80105793:	51                   	push   %ecx
80105794:	50                   	push   %eax
80105795:	ff 75 08             	pushl  0x8(%ebp)
80105798:	e8 8b ff ff ff       	call   80105728 <stosl>
8010579d:	83 c4 0c             	add    $0xc,%esp
801057a0:	eb 12                	jmp    801057b4 <memset+0x66>
  } else
    stosb(dst, c, n);
801057a2:	8b 45 10             	mov    0x10(%ebp),%eax
801057a5:	50                   	push   %eax
801057a6:	ff 75 0c             	pushl  0xc(%ebp)
801057a9:	ff 75 08             	pushl  0x8(%ebp)
801057ac:	e8 51 ff ff ff       	call   80105702 <stosb>
801057b1:	83 c4 0c             	add    $0xc,%esp
  return dst;
801057b4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801057b7:	c9                   	leave  
801057b8:	c3                   	ret    

801057b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801057b9:	f3 0f 1e fb          	endbr32 
801057bd:	55                   	push   %ebp
801057be:	89 e5                	mov    %esp,%ebp
801057c0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801057c3:	8b 45 08             	mov    0x8(%ebp),%eax
801057c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801057c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801057cc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801057cf:	eb 30                	jmp    80105801 <memcmp+0x48>
    if(*s1 != *s2)
801057d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d4:	0f b6 10             	movzbl (%eax),%edx
801057d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057da:	0f b6 00             	movzbl (%eax),%eax
801057dd:	38 c2                	cmp    %al,%dl
801057df:	74 18                	je     801057f9 <memcmp+0x40>
      return *s1 - *s2;
801057e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057e4:	0f b6 00             	movzbl (%eax),%eax
801057e7:	0f b6 d0             	movzbl %al,%edx
801057ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057ed:	0f b6 00             	movzbl (%eax),%eax
801057f0:	0f b6 c0             	movzbl %al,%eax
801057f3:	29 c2                	sub    %eax,%edx
801057f5:	89 d0                	mov    %edx,%eax
801057f7:	eb 1a                	jmp    80105813 <memcmp+0x5a>
    s1++, s2++;
801057f9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105801:	8b 45 10             	mov    0x10(%ebp),%eax
80105804:	8d 50 ff             	lea    -0x1(%eax),%edx
80105807:	89 55 10             	mov    %edx,0x10(%ebp)
8010580a:	85 c0                	test   %eax,%eax
8010580c:	75 c3                	jne    801057d1 <memcmp+0x18>
  }

  return 0;
8010580e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105813:	c9                   	leave  
80105814:	c3                   	ret    

80105815 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105815:	f3 0f 1e fb          	endbr32 
80105819:	55                   	push   %ebp
8010581a:	89 e5                	mov    %esp,%ebp
8010581c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010581f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105822:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010582b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010582e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105831:	73 54                	jae    80105887 <memmove+0x72>
80105833:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105836:	8b 45 10             	mov    0x10(%ebp),%eax
80105839:	01 d0                	add    %edx,%eax
8010583b:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010583e:	73 47                	jae    80105887 <memmove+0x72>
    s += n;
80105840:	8b 45 10             	mov    0x10(%ebp),%eax
80105843:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105846:	8b 45 10             	mov    0x10(%ebp),%eax
80105849:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010584c:	eb 13                	jmp    80105861 <memmove+0x4c>
      *--d = *--s;
8010584e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105852:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105856:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105859:	0f b6 10             	movzbl (%eax),%edx
8010585c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010585f:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105861:	8b 45 10             	mov    0x10(%ebp),%eax
80105864:	8d 50 ff             	lea    -0x1(%eax),%edx
80105867:	89 55 10             	mov    %edx,0x10(%ebp)
8010586a:	85 c0                	test   %eax,%eax
8010586c:	75 e0                	jne    8010584e <memmove+0x39>
  if(s < d && s + n > d){
8010586e:	eb 24                	jmp    80105894 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105870:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105873:	8d 42 01             	lea    0x1(%edx),%eax
80105876:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105879:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010587c:	8d 48 01             	lea    0x1(%eax),%ecx
8010587f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105882:	0f b6 12             	movzbl (%edx),%edx
80105885:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105887:	8b 45 10             	mov    0x10(%ebp),%eax
8010588a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010588d:	89 55 10             	mov    %edx,0x10(%ebp)
80105890:	85 c0                	test   %eax,%eax
80105892:	75 dc                	jne    80105870 <memmove+0x5b>

  return dst;
80105894:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105897:	c9                   	leave  
80105898:	c3                   	ret    

80105899 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105899:	f3 0f 1e fb          	endbr32 
8010589d:	55                   	push   %ebp
8010589e:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801058a0:	ff 75 10             	pushl  0x10(%ebp)
801058a3:	ff 75 0c             	pushl  0xc(%ebp)
801058a6:	ff 75 08             	pushl  0x8(%ebp)
801058a9:	e8 67 ff ff ff       	call   80105815 <memmove>
801058ae:	83 c4 0c             	add    $0xc,%esp
}
801058b1:	c9                   	leave  
801058b2:	c3                   	ret    

801058b3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801058b3:	f3 0f 1e fb          	endbr32 
801058b7:	55                   	push   %ebp
801058b8:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801058ba:	eb 0c                	jmp    801058c8 <strncmp+0x15>
    n--, p++, q++;
801058bc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801058c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801058c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058cc:	74 1a                	je     801058e8 <strncmp+0x35>
801058ce:	8b 45 08             	mov    0x8(%ebp),%eax
801058d1:	0f b6 00             	movzbl (%eax),%eax
801058d4:	84 c0                	test   %al,%al
801058d6:	74 10                	je     801058e8 <strncmp+0x35>
801058d8:	8b 45 08             	mov    0x8(%ebp),%eax
801058db:	0f b6 10             	movzbl (%eax),%edx
801058de:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e1:	0f b6 00             	movzbl (%eax),%eax
801058e4:	38 c2                	cmp    %al,%dl
801058e6:	74 d4                	je     801058bc <strncmp+0x9>
  if(n == 0)
801058e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058ec:	75 07                	jne    801058f5 <strncmp+0x42>
    return 0;
801058ee:	b8 00 00 00 00       	mov    $0x0,%eax
801058f3:	eb 16                	jmp    8010590b <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801058f5:	8b 45 08             	mov    0x8(%ebp),%eax
801058f8:	0f b6 00             	movzbl (%eax),%eax
801058fb:	0f b6 d0             	movzbl %al,%edx
801058fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105901:	0f b6 00             	movzbl (%eax),%eax
80105904:	0f b6 c0             	movzbl %al,%eax
80105907:	29 c2                	sub    %eax,%edx
80105909:	89 d0                	mov    %edx,%eax
}
8010590b:	5d                   	pop    %ebp
8010590c:	c3                   	ret    

8010590d <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010590d:	f3 0f 1e fb          	endbr32 
80105911:	55                   	push   %ebp
80105912:	89 e5                	mov    %esp,%ebp
80105914:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105917:	8b 45 08             	mov    0x8(%ebp),%eax
8010591a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010591d:	90                   	nop
8010591e:	8b 45 10             	mov    0x10(%ebp),%eax
80105921:	8d 50 ff             	lea    -0x1(%eax),%edx
80105924:	89 55 10             	mov    %edx,0x10(%ebp)
80105927:	85 c0                	test   %eax,%eax
80105929:	7e 2c                	jle    80105957 <strncpy+0x4a>
8010592b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010592e:	8d 42 01             	lea    0x1(%edx),%eax
80105931:	89 45 0c             	mov    %eax,0xc(%ebp)
80105934:	8b 45 08             	mov    0x8(%ebp),%eax
80105937:	8d 48 01             	lea    0x1(%eax),%ecx
8010593a:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010593d:	0f b6 12             	movzbl (%edx),%edx
80105940:	88 10                	mov    %dl,(%eax)
80105942:	0f b6 00             	movzbl (%eax),%eax
80105945:	84 c0                	test   %al,%al
80105947:	75 d5                	jne    8010591e <strncpy+0x11>
    ;
  while(n-- > 0)
80105949:	eb 0c                	jmp    80105957 <strncpy+0x4a>
    *s++ = 0;
8010594b:	8b 45 08             	mov    0x8(%ebp),%eax
8010594e:	8d 50 01             	lea    0x1(%eax),%edx
80105951:	89 55 08             	mov    %edx,0x8(%ebp)
80105954:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80105957:	8b 45 10             	mov    0x10(%ebp),%eax
8010595a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010595d:	89 55 10             	mov    %edx,0x10(%ebp)
80105960:	85 c0                	test   %eax,%eax
80105962:	7f e7                	jg     8010594b <strncpy+0x3e>
  return os;
80105964:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105967:	c9                   	leave  
80105968:	c3                   	ret    

80105969 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105969:	f3 0f 1e fb          	endbr32 
8010596d:	55                   	push   %ebp
8010596e:	89 e5                	mov    %esp,%ebp
80105970:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105973:	8b 45 08             	mov    0x8(%ebp),%eax
80105976:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105979:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010597d:	7f 05                	jg     80105984 <safestrcpy+0x1b>
    return os;
8010597f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105982:	eb 31                	jmp    801059b5 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105984:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105988:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010598c:	7e 1e                	jle    801059ac <safestrcpy+0x43>
8010598e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105991:	8d 42 01             	lea    0x1(%edx),%eax
80105994:	89 45 0c             	mov    %eax,0xc(%ebp)
80105997:	8b 45 08             	mov    0x8(%ebp),%eax
8010599a:	8d 48 01             	lea    0x1(%eax),%ecx
8010599d:	89 4d 08             	mov    %ecx,0x8(%ebp)
801059a0:	0f b6 12             	movzbl (%edx),%edx
801059a3:	88 10                	mov    %dl,(%eax)
801059a5:	0f b6 00             	movzbl (%eax),%eax
801059a8:	84 c0                	test   %al,%al
801059aa:	75 d8                	jne    80105984 <safestrcpy+0x1b>
    ;
  *s = 0;
801059ac:	8b 45 08             	mov    0x8(%ebp),%eax
801059af:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801059b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059b5:	c9                   	leave  
801059b6:	c3                   	ret    

801059b7 <strlen>:

int
strlen(const char *s)
{
801059b7:	f3 0f 1e fb          	endbr32 
801059bb:	55                   	push   %ebp
801059bc:	89 e5                	mov    %esp,%ebp
801059be:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801059c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059c8:	eb 04                	jmp    801059ce <strlen+0x17>
801059ca:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059d1:	8b 45 08             	mov    0x8(%ebp),%eax
801059d4:	01 d0                	add    %edx,%eax
801059d6:	0f b6 00             	movzbl (%eax),%eax
801059d9:	84 c0                	test   %al,%al
801059db:	75 ed                	jne    801059ca <strlen+0x13>
    ;
  return n;
801059dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059e0:	c9                   	leave  
801059e1:	c3                   	ret    

801059e2 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801059e2:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801059e6:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801059ea:	55                   	push   %ebp
  pushl %ebx
801059eb:	53                   	push   %ebx
  pushl %esi
801059ec:	56                   	push   %esi
  pushl %edi
801059ed:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801059ee:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801059f0:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801059f2:	5f                   	pop    %edi
  popl %esi
801059f3:	5e                   	pop    %esi
  popl %ebx
801059f4:	5b                   	pop    %ebx
  popl %ebp
801059f5:	5d                   	pop    %ebp
  ret
801059f6:	c3                   	ret    

801059f7 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801059f7:	f3 0f 1e fb          	endbr32 
801059fb:	55                   	push   %ebp
801059fc:	89 e5                	mov    %esp,%ebp
801059fe:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105a01:	e8 2a eb ff ff       	call   80104530 <myproc>
80105a06:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	8b 00                	mov    (%eax),%eax
80105a0e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105a11:	73 0f                	jae    80105a22 <fetchint+0x2b>
80105a13:	8b 45 08             	mov    0x8(%ebp),%eax
80105a16:	8d 50 04             	lea    0x4(%eax),%edx
80105a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1c:	8b 00                	mov    (%eax),%eax
80105a1e:	39 c2                	cmp    %eax,%edx
80105a20:	76 07                	jbe    80105a29 <fetchint+0x32>
    return -1;
80105a22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a27:	eb 0f                	jmp    80105a38 <fetchint+0x41>
  *ip = *(int*)(addr);
80105a29:	8b 45 08             	mov    0x8(%ebp),%eax
80105a2c:	8b 10                	mov    (%eax),%edx
80105a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a31:	89 10                	mov    %edx,(%eax)
  return 0;
80105a33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a38:	c9                   	leave  
80105a39:	c3                   	ret    

80105a3a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105a3a:	f3 0f 1e fb          	endbr32 
80105a3e:	55                   	push   %ebp
80105a3f:	89 e5                	mov    %esp,%ebp
80105a41:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105a44:	e8 e7 ea ff ff       	call   80104530 <myproc>
80105a49:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a4f:	8b 00                	mov    (%eax),%eax
80105a51:	39 45 08             	cmp    %eax,0x8(%ebp)
80105a54:	72 07                	jb     80105a5d <fetchstr+0x23>
    return -1;
80105a56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a5b:	eb 43                	jmp    80105aa0 <fetchstr+0x66>
  *pp = (char*)addr;
80105a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80105a60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a63:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a68:	8b 00                	mov    (%eax),%eax
80105a6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a70:	8b 00                	mov    (%eax),%eax
80105a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a75:	eb 1c                	jmp    80105a93 <fetchstr+0x59>
    if(*s == 0)
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	0f b6 00             	movzbl (%eax),%eax
80105a7d:	84 c0                	test   %al,%al
80105a7f:	75 0e                	jne    80105a8f <fetchstr+0x55>
      return s - *pp;
80105a81:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a84:	8b 00                	mov    (%eax),%eax
80105a86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a89:	29 c2                	sub    %eax,%edx
80105a8b:	89 d0                	mov    %edx,%eax
80105a8d:	eb 11                	jmp    80105aa0 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105a8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105a99:	72 dc                	jb     80105a77 <fetchstr+0x3d>
  }
  return -1;
80105a9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105aa0:	c9                   	leave  
80105aa1:	c3                   	ret    

80105aa2 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105aa2:	f3 0f 1e fb          	endbr32 
80105aa6:	55                   	push   %ebp
80105aa7:	89 e5                	mov    %esp,%ebp
80105aa9:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105aac:	e8 7f ea ff ff       	call   80104530 <myproc>
80105ab1:	8b 40 18             	mov    0x18(%eax),%eax
80105ab4:	8b 40 44             	mov    0x44(%eax),%eax
80105ab7:	8b 55 08             	mov    0x8(%ebp),%edx
80105aba:	c1 e2 02             	shl    $0x2,%edx
80105abd:	01 d0                	add    %edx,%eax
80105abf:	83 c0 04             	add    $0x4,%eax
80105ac2:	83 ec 08             	sub    $0x8,%esp
80105ac5:	ff 75 0c             	pushl  0xc(%ebp)
80105ac8:	50                   	push   %eax
80105ac9:	e8 29 ff ff ff       	call   801059f7 <fetchint>
80105ace:	83 c4 10             	add    $0x10,%esp
}
80105ad1:	c9                   	leave  
80105ad2:	c3                   	ret    

80105ad3 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105ad3:	f3 0f 1e fb          	endbr32 
80105ad7:	55                   	push   %ebp
80105ad8:	89 e5                	mov    %esp,%ebp
80105ada:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105add:	e8 4e ea ff ff       	call   80104530 <myproc>
80105ae2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105ae5:	83 ec 08             	sub    $0x8,%esp
80105ae8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105aeb:	50                   	push   %eax
80105aec:	ff 75 08             	pushl  0x8(%ebp)
80105aef:	e8 ae ff ff ff       	call   80105aa2 <argint>
80105af4:	83 c4 10             	add    $0x10,%esp
80105af7:	85 c0                	test   %eax,%eax
80105af9:	79 07                	jns    80105b02 <argptr+0x2f>
    return -1;
80105afb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b00:	eb 3b                	jmp    80105b3d <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105b02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b06:	78 1f                	js     80105b27 <argptr+0x54>
80105b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0b:	8b 00                	mov    (%eax),%eax
80105b0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b10:	39 d0                	cmp    %edx,%eax
80105b12:	76 13                	jbe    80105b27 <argptr+0x54>
80105b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b17:	89 c2                	mov    %eax,%edx
80105b19:	8b 45 10             	mov    0x10(%ebp),%eax
80105b1c:	01 c2                	add    %eax,%edx
80105b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b21:	8b 00                	mov    (%eax),%eax
80105b23:	39 c2                	cmp    %eax,%edx
80105b25:	76 07                	jbe    80105b2e <argptr+0x5b>
    return -1;
80105b27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2c:	eb 0f                	jmp    80105b3d <argptr+0x6a>
  *pp = (char*)i;
80105b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b31:	89 c2                	mov    %eax,%edx
80105b33:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b36:	89 10                	mov    %edx,(%eax)
  return 0;
80105b38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b3d:	c9                   	leave  
80105b3e:	c3                   	ret    

80105b3f <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105b3f:	f3 0f 1e fb          	endbr32 
80105b43:	55                   	push   %ebp
80105b44:	89 e5                	mov    %esp,%ebp
80105b46:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105b49:	83 ec 08             	sub    $0x8,%esp
80105b4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b4f:	50                   	push   %eax
80105b50:	ff 75 08             	pushl  0x8(%ebp)
80105b53:	e8 4a ff ff ff       	call   80105aa2 <argint>
80105b58:	83 c4 10             	add    $0x10,%esp
80105b5b:	85 c0                	test   %eax,%eax
80105b5d:	79 07                	jns    80105b66 <argstr+0x27>
    return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b64:	eb 12                	jmp    80105b78 <argstr+0x39>
  return fetchstr(addr, pp);
80105b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b69:	83 ec 08             	sub    $0x8,%esp
80105b6c:	ff 75 0c             	pushl  0xc(%ebp)
80105b6f:	50                   	push   %eax
80105b70:	e8 c5 fe ff ff       	call   80105a3a <fetchstr>
80105b75:	83 c4 10             	add    $0x10,%esp
}
80105b78:	c9                   	leave  
80105b79:	c3                   	ret    

80105b7a <syscall>:
[SYS_dump_rawphymem] sys_dump_rawphymem,
};

void
syscall(void)
{
80105b7a:	f3 0f 1e fb          	endbr32 
80105b7e:	55                   	push   %ebp
80105b7f:	89 e5                	mov    %esp,%ebp
80105b81:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105b84:	e8 a7 e9 ff ff       	call   80104530 <myproc>
80105b89:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8f:	8b 40 18             	mov    0x18(%eax),%eax
80105b92:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105b98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b9c:	7e 2f                	jle    80105bcd <syscall+0x53>
80105b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba1:	83 f8 18             	cmp    $0x18,%eax
80105ba4:	77 27                	ja     80105bcd <syscall+0x53>
80105ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba9:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105bb0:	85 c0                	test   %eax,%eax
80105bb2:	74 19                	je     80105bcd <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb7:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
80105bbe:	ff d0                	call   *%eax
80105bc0:	89 c2                	mov    %eax,%edx
80105bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc5:	8b 40 18             	mov    0x18(%eax),%eax
80105bc8:	89 50 1c             	mov    %edx,0x1c(%eax)
80105bcb:	eb 2c                	jmp    80105bf9 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd0:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd6:	8b 40 10             	mov    0x10(%eax),%eax
80105bd9:	ff 75 f0             	pushl  -0x10(%ebp)
80105bdc:	52                   	push   %edx
80105bdd:	50                   	push   %eax
80105bde:	68 28 9b 10 80       	push   $0x80109b28
80105be3:	e8 30 a8 ff ff       	call   80100418 <cprintf>
80105be8:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bee:	8b 40 18             	mov    0x18(%eax),%eax
80105bf1:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105bf8:	90                   	nop
80105bf9:	90                   	nop
80105bfa:	c9                   	leave  
80105bfb:	c3                   	ret    

80105bfc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105bfc:	f3 0f 1e fb          	endbr32 
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105c06:	83 ec 08             	sub    $0x8,%esp
80105c09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c0c:	50                   	push   %eax
80105c0d:	ff 75 08             	pushl  0x8(%ebp)
80105c10:	e8 8d fe ff ff       	call   80105aa2 <argint>
80105c15:	83 c4 10             	add    $0x10,%esp
80105c18:	85 c0                	test   %eax,%eax
80105c1a:	79 07                	jns    80105c23 <argfd+0x27>
    return -1;
80105c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c21:	eb 4f                	jmp    80105c72 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c26:	85 c0                	test   %eax,%eax
80105c28:	78 20                	js     80105c4a <argfd+0x4e>
80105c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2d:	83 f8 0f             	cmp    $0xf,%eax
80105c30:	7f 18                	jg     80105c4a <argfd+0x4e>
80105c32:	e8 f9 e8 ff ff       	call   80104530 <myproc>
80105c37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c3a:	83 c2 08             	add    $0x8,%edx
80105c3d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c48:	75 07                	jne    80105c51 <argfd+0x55>
    return -1;
80105c4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c4f:	eb 21                	jmp    80105c72 <argfd+0x76>
  if(pfd)
80105c51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105c55:	74 08                	je     80105c5f <argfd+0x63>
    *pfd = fd;
80105c57:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c5d:	89 10                	mov    %edx,(%eax)
  if(pf)
80105c5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c63:	74 08                	je     80105c6d <argfd+0x71>
    *pf = f;
80105c65:	8b 45 10             	mov    0x10(%ebp),%eax
80105c68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c6b:	89 10                	mov    %edx,(%eax)
  return 0;
80105c6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c72:	c9                   	leave  
80105c73:	c3                   	ret    

80105c74 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c74:	f3 0f 1e fb          	endbr32 
80105c78:	55                   	push   %ebp
80105c79:	89 e5                	mov    %esp,%ebp
80105c7b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105c7e:	e8 ad e8 ff ff       	call   80104530 <myproc>
80105c83:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105c86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c8d:	eb 2a                	jmp    80105cb9 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c95:	83 c2 08             	add    $0x8,%edx
80105c98:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c9c:	85 c0                	test   %eax,%eax
80105c9e:	75 15                	jne    80105cb5 <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ca6:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ca9:	8b 55 08             	mov    0x8(%ebp),%edx
80105cac:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cb3:	eb 0f                	jmp    80105cc4 <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105cb5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105cb9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105cbd:	7e d0                	jle    80105c8f <fdalloc+0x1b>
    }
  }
  return -1;
80105cbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cc4:	c9                   	leave  
80105cc5:	c3                   	ret    

80105cc6 <sys_dup>:

int
sys_dup(void)
{
80105cc6:	f3 0f 1e fb          	endbr32 
80105cca:	55                   	push   %ebp
80105ccb:	89 e5                	mov    %esp,%ebp
80105ccd:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105cd0:	83 ec 04             	sub    $0x4,%esp
80105cd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cd6:	50                   	push   %eax
80105cd7:	6a 00                	push   $0x0
80105cd9:	6a 00                	push   $0x0
80105cdb:	e8 1c ff ff ff       	call   80105bfc <argfd>
80105ce0:	83 c4 10             	add    $0x10,%esp
80105ce3:	85 c0                	test   %eax,%eax
80105ce5:	79 07                	jns    80105cee <sys_dup+0x28>
    return -1;
80105ce7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cec:	eb 31                	jmp    80105d1f <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf1:	83 ec 0c             	sub    $0xc,%esp
80105cf4:	50                   	push   %eax
80105cf5:	e8 7a ff ff ff       	call   80105c74 <fdalloc>
80105cfa:	83 c4 10             	add    $0x10,%esp
80105cfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d04:	79 07                	jns    80105d0d <sys_dup+0x47>
    return -1;
80105d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d0b:	eb 12                	jmp    80105d1f <sys_dup+0x59>
  filedup(f);
80105d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d10:	83 ec 0c             	sub    $0xc,%esp
80105d13:	50                   	push   %eax
80105d14:	e8 8e b4 ff ff       	call   801011a7 <filedup>
80105d19:	83 c4 10             	add    $0x10,%esp
  return fd;
80105d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d1f:	c9                   	leave  
80105d20:	c3                   	ret    

80105d21 <sys_read>:

int
sys_read(void)
{
80105d21:	f3 0f 1e fb          	endbr32 
80105d25:	55                   	push   %ebp
80105d26:	89 e5                	mov    %esp,%ebp
80105d28:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d2b:	83 ec 04             	sub    $0x4,%esp
80105d2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d31:	50                   	push   %eax
80105d32:	6a 00                	push   $0x0
80105d34:	6a 00                	push   $0x0
80105d36:	e8 c1 fe ff ff       	call   80105bfc <argfd>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	85 c0                	test   %eax,%eax
80105d40:	78 2e                	js     80105d70 <sys_read+0x4f>
80105d42:	83 ec 08             	sub    $0x8,%esp
80105d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d48:	50                   	push   %eax
80105d49:	6a 02                	push   $0x2
80105d4b:	e8 52 fd ff ff       	call   80105aa2 <argint>
80105d50:	83 c4 10             	add    $0x10,%esp
80105d53:	85 c0                	test   %eax,%eax
80105d55:	78 19                	js     80105d70 <sys_read+0x4f>
80105d57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5a:	83 ec 04             	sub    $0x4,%esp
80105d5d:	50                   	push   %eax
80105d5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d61:	50                   	push   %eax
80105d62:	6a 01                	push   $0x1
80105d64:	e8 6a fd ff ff       	call   80105ad3 <argptr>
80105d69:	83 c4 10             	add    $0x10,%esp
80105d6c:	85 c0                	test   %eax,%eax
80105d6e:	79 07                	jns    80105d77 <sys_read+0x56>
    return -1;
80105d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d75:	eb 17                	jmp    80105d8e <sys_read+0x6d>
  return fileread(f, p, n);
80105d77:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d7a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d80:	83 ec 04             	sub    $0x4,%esp
80105d83:	51                   	push   %ecx
80105d84:	52                   	push   %edx
80105d85:	50                   	push   %eax
80105d86:	e8 b8 b5 ff ff       	call   80101343 <fileread>
80105d8b:	83 c4 10             	add    $0x10,%esp
}
80105d8e:	c9                   	leave  
80105d8f:	c3                   	ret    

80105d90 <sys_write>:

int
sys_write(void)
{
80105d90:	f3 0f 1e fb          	endbr32 
80105d94:	55                   	push   %ebp
80105d95:	89 e5                	mov    %esp,%ebp
80105d97:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d9a:	83 ec 04             	sub    $0x4,%esp
80105d9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105da0:	50                   	push   %eax
80105da1:	6a 00                	push   $0x0
80105da3:	6a 00                	push   $0x0
80105da5:	e8 52 fe ff ff       	call   80105bfc <argfd>
80105daa:	83 c4 10             	add    $0x10,%esp
80105dad:	85 c0                	test   %eax,%eax
80105daf:	78 2e                	js     80105ddf <sys_write+0x4f>
80105db1:	83 ec 08             	sub    $0x8,%esp
80105db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105db7:	50                   	push   %eax
80105db8:	6a 02                	push   $0x2
80105dba:	e8 e3 fc ff ff       	call   80105aa2 <argint>
80105dbf:	83 c4 10             	add    $0x10,%esp
80105dc2:	85 c0                	test   %eax,%eax
80105dc4:	78 19                	js     80105ddf <sys_write+0x4f>
80105dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc9:	83 ec 04             	sub    $0x4,%esp
80105dcc:	50                   	push   %eax
80105dcd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dd0:	50                   	push   %eax
80105dd1:	6a 01                	push   $0x1
80105dd3:	e8 fb fc ff ff       	call   80105ad3 <argptr>
80105dd8:	83 c4 10             	add    $0x10,%esp
80105ddb:	85 c0                	test   %eax,%eax
80105ddd:	79 07                	jns    80105de6 <sys_write+0x56>
    return -1;
80105ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de4:	eb 17                	jmp    80105dfd <sys_write+0x6d>
  return filewrite(f, p, n);
80105de6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105de9:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105def:	83 ec 04             	sub    $0x4,%esp
80105df2:	51                   	push   %ecx
80105df3:	52                   	push   %edx
80105df4:	50                   	push   %eax
80105df5:	e8 05 b6 ff ff       	call   801013ff <filewrite>
80105dfa:	83 c4 10             	add    $0x10,%esp
}
80105dfd:	c9                   	leave  
80105dfe:	c3                   	ret    

80105dff <sys_close>:

int
sys_close(void)
{
80105dff:	f3 0f 1e fb          	endbr32 
80105e03:	55                   	push   %ebp
80105e04:	89 e5                	mov    %esp,%ebp
80105e06:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105e09:	83 ec 04             	sub    $0x4,%esp
80105e0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e0f:	50                   	push   %eax
80105e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e13:	50                   	push   %eax
80105e14:	6a 00                	push   $0x0
80105e16:	e8 e1 fd ff ff       	call   80105bfc <argfd>
80105e1b:	83 c4 10             	add    $0x10,%esp
80105e1e:	85 c0                	test   %eax,%eax
80105e20:	79 07                	jns    80105e29 <sys_close+0x2a>
    return -1;
80105e22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e27:	eb 27                	jmp    80105e50 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105e29:	e8 02 e7 ff ff       	call   80104530 <myproc>
80105e2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e31:	83 c2 08             	add    $0x8,%edx
80105e34:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105e3b:	00 
  fileclose(f);
80105e3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3f:	83 ec 0c             	sub    $0xc,%esp
80105e42:	50                   	push   %eax
80105e43:	e8 b4 b3 ff ff       	call   801011fc <fileclose>
80105e48:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e50:	c9                   	leave  
80105e51:	c3                   	ret    

80105e52 <sys_fstat>:

int
sys_fstat(void)
{
80105e52:	f3 0f 1e fb          	endbr32 
80105e56:	55                   	push   %ebp
80105e57:	89 e5                	mov    %esp,%ebp
80105e59:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105e5c:	83 ec 04             	sub    $0x4,%esp
80105e5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e62:	50                   	push   %eax
80105e63:	6a 00                	push   $0x0
80105e65:	6a 00                	push   $0x0
80105e67:	e8 90 fd ff ff       	call   80105bfc <argfd>
80105e6c:	83 c4 10             	add    $0x10,%esp
80105e6f:	85 c0                	test   %eax,%eax
80105e71:	78 17                	js     80105e8a <sys_fstat+0x38>
80105e73:	83 ec 04             	sub    $0x4,%esp
80105e76:	6a 14                	push   $0x14
80105e78:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e7b:	50                   	push   %eax
80105e7c:	6a 01                	push   $0x1
80105e7e:	e8 50 fc ff ff       	call   80105ad3 <argptr>
80105e83:	83 c4 10             	add    $0x10,%esp
80105e86:	85 c0                	test   %eax,%eax
80105e88:	79 07                	jns    80105e91 <sys_fstat+0x3f>
    return -1;
80105e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8f:	eb 13                	jmp    80105ea4 <sys_fstat+0x52>
  return filestat(f, st);
80105e91:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e97:	83 ec 08             	sub    $0x8,%esp
80105e9a:	52                   	push   %edx
80105e9b:	50                   	push   %eax
80105e9c:	e8 47 b4 ff ff       	call   801012e8 <filestat>
80105ea1:	83 c4 10             	add    $0x10,%esp
}
80105ea4:	c9                   	leave  
80105ea5:	c3                   	ret    

80105ea6 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105ea6:	f3 0f 1e fb          	endbr32 
80105eaa:	55                   	push   %ebp
80105eab:	89 e5                	mov    %esp,%ebp
80105ead:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105eb0:	83 ec 08             	sub    $0x8,%esp
80105eb3:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105eb6:	50                   	push   %eax
80105eb7:	6a 00                	push   $0x0
80105eb9:	e8 81 fc ff ff       	call   80105b3f <argstr>
80105ebe:	83 c4 10             	add    $0x10,%esp
80105ec1:	85 c0                	test   %eax,%eax
80105ec3:	78 15                	js     80105eda <sys_link+0x34>
80105ec5:	83 ec 08             	sub    $0x8,%esp
80105ec8:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ecb:	50                   	push   %eax
80105ecc:	6a 01                	push   $0x1
80105ece:	e8 6c fc ff ff       	call   80105b3f <argstr>
80105ed3:	83 c4 10             	add    $0x10,%esp
80105ed6:	85 c0                	test   %eax,%eax
80105ed8:	79 0a                	jns    80105ee4 <sys_link+0x3e>
    return -1;
80105eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edf:	e9 68 01 00 00       	jmp    8010604c <sys_link+0x1a6>

  begin_op();
80105ee4:	e8 88 d8 ff ff       	call   80103771 <begin_op>
  if((ip = namei(old)) == 0){
80105ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105eec:	83 ec 0c             	sub    $0xc,%esp
80105eef:	50                   	push   %eax
80105ef0:	e8 f2 c7 ff ff       	call   801026e7 <namei>
80105ef5:	83 c4 10             	add    $0x10,%esp
80105ef8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105efb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105eff:	75 0f                	jne    80105f10 <sys_link+0x6a>
    end_op();
80105f01:	e8 fb d8 ff ff       	call   80103801 <end_op>
    return -1;
80105f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f0b:	e9 3c 01 00 00       	jmp    8010604c <sys_link+0x1a6>
  }

  ilock(ip);
80105f10:	83 ec 0c             	sub    $0xc,%esp
80105f13:	ff 75 f4             	pushl  -0xc(%ebp)
80105f16:	e8 61 bc ff ff       	call   80101b7c <ilock>
80105f1b:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f21:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f25:	66 83 f8 01          	cmp    $0x1,%ax
80105f29:	75 1d                	jne    80105f48 <sys_link+0xa2>
    iunlockput(ip);
80105f2b:	83 ec 0c             	sub    $0xc,%esp
80105f2e:	ff 75 f4             	pushl  -0xc(%ebp)
80105f31:	e8 83 be ff ff       	call   80101db9 <iunlockput>
80105f36:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f39:	e8 c3 d8 ff ff       	call   80103801 <end_op>
    return -1;
80105f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f43:	e9 04 01 00 00       	jmp    8010604c <sys_link+0x1a6>
  }

  ip->nlink++;
80105f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4b:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f4f:	83 c0 01             	add    $0x1,%eax
80105f52:	89 c2                	mov    %eax,%edx
80105f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f57:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105f5b:	83 ec 0c             	sub    $0xc,%esp
80105f5e:	ff 75 f4             	pushl  -0xc(%ebp)
80105f61:	e8 2d ba ff ff       	call   80101993 <iupdate>
80105f66:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105f69:	83 ec 0c             	sub    $0xc,%esp
80105f6c:	ff 75 f4             	pushl  -0xc(%ebp)
80105f6f:	e8 1f bd ff ff       	call   80101c93 <iunlock>
80105f74:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105f77:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105f7a:	83 ec 08             	sub    $0x8,%esp
80105f7d:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105f80:	52                   	push   %edx
80105f81:	50                   	push   %eax
80105f82:	e8 80 c7 ff ff       	call   80102707 <nameiparent>
80105f87:	83 c4 10             	add    $0x10,%esp
80105f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f8d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f91:	74 71                	je     80106004 <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105f93:	83 ec 0c             	sub    $0xc,%esp
80105f96:	ff 75 f0             	pushl  -0x10(%ebp)
80105f99:	e8 de bb ff ff       	call   80101b7c <ilock>
80105f9e:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105fa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa4:	8b 10                	mov    (%eax),%edx
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	8b 00                	mov    (%eax),%eax
80105fab:	39 c2                	cmp    %eax,%edx
80105fad:	75 1d                	jne    80105fcc <sys_link+0x126>
80105faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb2:	8b 40 04             	mov    0x4(%eax),%eax
80105fb5:	83 ec 04             	sub    $0x4,%esp
80105fb8:	50                   	push   %eax
80105fb9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fbc:	50                   	push   %eax
80105fbd:	ff 75 f0             	pushl  -0x10(%ebp)
80105fc0:	e8 7f c4 ff ff       	call   80102444 <dirlink>
80105fc5:	83 c4 10             	add    $0x10,%esp
80105fc8:	85 c0                	test   %eax,%eax
80105fca:	79 10                	jns    80105fdc <sys_link+0x136>
    iunlockput(dp);
80105fcc:	83 ec 0c             	sub    $0xc,%esp
80105fcf:	ff 75 f0             	pushl  -0x10(%ebp)
80105fd2:	e8 e2 bd ff ff       	call   80101db9 <iunlockput>
80105fd7:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105fda:	eb 29                	jmp    80106005 <sys_link+0x15f>
  }
  iunlockput(dp);
80105fdc:	83 ec 0c             	sub    $0xc,%esp
80105fdf:	ff 75 f0             	pushl  -0x10(%ebp)
80105fe2:	e8 d2 bd ff ff       	call   80101db9 <iunlockput>
80105fe7:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105fea:	83 ec 0c             	sub    $0xc,%esp
80105fed:	ff 75 f4             	pushl  -0xc(%ebp)
80105ff0:	e8 f0 bc ff ff       	call   80101ce5 <iput>
80105ff5:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ff8:	e8 04 d8 ff ff       	call   80103801 <end_op>

  return 0;
80105ffd:	b8 00 00 00 00       	mov    $0x0,%eax
80106002:	eb 48                	jmp    8010604c <sys_link+0x1a6>
    goto bad;
80106004:	90                   	nop

bad:
  ilock(ip);
80106005:	83 ec 0c             	sub    $0xc,%esp
80106008:	ff 75 f4             	pushl  -0xc(%ebp)
8010600b:	e8 6c bb ff ff       	call   80101b7c <ilock>
80106010:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106016:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010601a:	83 e8 01             	sub    $0x1,%eax
8010601d:	89 c2                	mov    %eax,%edx
8010601f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106022:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106026:	83 ec 0c             	sub    $0xc,%esp
80106029:	ff 75 f4             	pushl  -0xc(%ebp)
8010602c:	e8 62 b9 ff ff       	call   80101993 <iupdate>
80106031:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106034:	83 ec 0c             	sub    $0xc,%esp
80106037:	ff 75 f4             	pushl  -0xc(%ebp)
8010603a:	e8 7a bd ff ff       	call   80101db9 <iunlockput>
8010603f:	83 c4 10             	add    $0x10,%esp
  end_op();
80106042:	e8 ba d7 ff ff       	call   80103801 <end_op>
  return -1;
80106047:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010604c:	c9                   	leave  
8010604d:	c3                   	ret    

8010604e <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010604e:	f3 0f 1e fb          	endbr32 
80106052:	55                   	push   %ebp
80106053:	89 e5                	mov    %esp,%ebp
80106055:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106058:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010605f:	eb 40                	jmp    801060a1 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106064:	6a 10                	push   $0x10
80106066:	50                   	push   %eax
80106067:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010606a:	50                   	push   %eax
8010606b:	ff 75 08             	pushl  0x8(%ebp)
8010606e:	e8 11 c0 ff ff       	call   80102084 <readi>
80106073:	83 c4 10             	add    $0x10,%esp
80106076:	83 f8 10             	cmp    $0x10,%eax
80106079:	74 0d                	je     80106088 <isdirempty+0x3a>
      panic("isdirempty: readi");
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	68 44 9b 10 80       	push   $0x80109b44
80106083:	e8 80 a5 ff ff       	call   80100608 <panic>
    if(de.inum != 0)
80106088:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010608c:	66 85 c0             	test   %ax,%ax
8010608f:	74 07                	je     80106098 <isdirempty+0x4a>
      return 0;
80106091:	b8 00 00 00 00       	mov    $0x0,%eax
80106096:	eb 1b                	jmp    801060b3 <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609b:	83 c0 10             	add    $0x10,%eax
8010609e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060a1:	8b 45 08             	mov    0x8(%ebp),%eax
801060a4:	8b 50 58             	mov    0x58(%eax),%edx
801060a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060aa:	39 c2                	cmp    %eax,%edx
801060ac:	77 b3                	ja     80106061 <isdirempty+0x13>
  }
  return 1;
801060ae:	b8 01 00 00 00       	mov    $0x1,%eax
}
801060b3:	c9                   	leave  
801060b4:	c3                   	ret    

801060b5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801060b5:	f3 0f 1e fb          	endbr32 
801060b9:	55                   	push   %ebp
801060ba:	89 e5                	mov    %esp,%ebp
801060bc:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801060bf:	83 ec 08             	sub    $0x8,%esp
801060c2:	8d 45 cc             	lea    -0x34(%ebp),%eax
801060c5:	50                   	push   %eax
801060c6:	6a 00                	push   $0x0
801060c8:	e8 72 fa ff ff       	call   80105b3f <argstr>
801060cd:	83 c4 10             	add    $0x10,%esp
801060d0:	85 c0                	test   %eax,%eax
801060d2:	79 0a                	jns    801060de <sys_unlink+0x29>
    return -1;
801060d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d9:	e9 bf 01 00 00       	jmp    8010629d <sys_unlink+0x1e8>

  begin_op();
801060de:	e8 8e d6 ff ff       	call   80103771 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801060e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
801060e6:	83 ec 08             	sub    $0x8,%esp
801060e9:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801060ec:	52                   	push   %edx
801060ed:	50                   	push   %eax
801060ee:	e8 14 c6 ff ff       	call   80102707 <nameiparent>
801060f3:	83 c4 10             	add    $0x10,%esp
801060f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060fd:	75 0f                	jne    8010610e <sys_unlink+0x59>
    end_op();
801060ff:	e8 fd d6 ff ff       	call   80103801 <end_op>
    return -1;
80106104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106109:	e9 8f 01 00 00       	jmp    8010629d <sys_unlink+0x1e8>
  }

  ilock(dp);
8010610e:	83 ec 0c             	sub    $0xc,%esp
80106111:	ff 75 f4             	pushl  -0xc(%ebp)
80106114:	e8 63 ba ff ff       	call   80101b7c <ilock>
80106119:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010611c:	83 ec 08             	sub    $0x8,%esp
8010611f:	68 56 9b 10 80       	push   $0x80109b56
80106124:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106127:	50                   	push   %eax
80106128:	e8 3a c2 ff ff       	call   80102367 <namecmp>
8010612d:	83 c4 10             	add    $0x10,%esp
80106130:	85 c0                	test   %eax,%eax
80106132:	0f 84 49 01 00 00    	je     80106281 <sys_unlink+0x1cc>
80106138:	83 ec 08             	sub    $0x8,%esp
8010613b:	68 58 9b 10 80       	push   $0x80109b58
80106140:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106143:	50                   	push   %eax
80106144:	e8 1e c2 ff ff       	call   80102367 <namecmp>
80106149:	83 c4 10             	add    $0x10,%esp
8010614c:	85 c0                	test   %eax,%eax
8010614e:	0f 84 2d 01 00 00    	je     80106281 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106154:	83 ec 04             	sub    $0x4,%esp
80106157:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010615a:	50                   	push   %eax
8010615b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010615e:	50                   	push   %eax
8010615f:	ff 75 f4             	pushl  -0xc(%ebp)
80106162:	e8 1f c2 ff ff       	call   80102386 <dirlookup>
80106167:	83 c4 10             	add    $0x10,%esp
8010616a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010616d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106171:	0f 84 0d 01 00 00    	je     80106284 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80106177:	83 ec 0c             	sub    $0xc,%esp
8010617a:	ff 75 f0             	pushl  -0x10(%ebp)
8010617d:	e8 fa b9 ff ff       	call   80101b7c <ilock>
80106182:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106185:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106188:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010618c:	66 85 c0             	test   %ax,%ax
8010618f:	7f 0d                	jg     8010619e <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80106191:	83 ec 0c             	sub    $0xc,%esp
80106194:	68 5b 9b 10 80       	push   $0x80109b5b
80106199:	e8 6a a4 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010619e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061a1:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801061a5:	66 83 f8 01          	cmp    $0x1,%ax
801061a9:	75 25                	jne    801061d0 <sys_unlink+0x11b>
801061ab:	83 ec 0c             	sub    $0xc,%esp
801061ae:	ff 75 f0             	pushl  -0x10(%ebp)
801061b1:	e8 98 fe ff ff       	call   8010604e <isdirempty>
801061b6:	83 c4 10             	add    $0x10,%esp
801061b9:	85 c0                	test   %eax,%eax
801061bb:	75 13                	jne    801061d0 <sys_unlink+0x11b>
    iunlockput(ip);
801061bd:	83 ec 0c             	sub    $0xc,%esp
801061c0:	ff 75 f0             	pushl  -0x10(%ebp)
801061c3:	e8 f1 bb ff ff       	call   80101db9 <iunlockput>
801061c8:	83 c4 10             	add    $0x10,%esp
    goto bad;
801061cb:	e9 b5 00 00 00       	jmp    80106285 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801061d0:	83 ec 04             	sub    $0x4,%esp
801061d3:	6a 10                	push   $0x10
801061d5:	6a 00                	push   $0x0
801061d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061da:	50                   	push   %eax
801061db:	e8 6e f5 ff ff       	call   8010574e <memset>
801061e0:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801061e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
801061e6:	6a 10                	push   $0x10
801061e8:	50                   	push   %eax
801061e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061ec:	50                   	push   %eax
801061ed:	ff 75 f4             	pushl  -0xc(%ebp)
801061f0:	e8 e8 bf ff ff       	call   801021dd <writei>
801061f5:	83 c4 10             	add    $0x10,%esp
801061f8:	83 f8 10             	cmp    $0x10,%eax
801061fb:	74 0d                	je     8010620a <sys_unlink+0x155>
    panic("unlink: writei");
801061fd:	83 ec 0c             	sub    $0xc,%esp
80106200:	68 6d 9b 10 80       	push   $0x80109b6d
80106205:	e8 fe a3 ff ff       	call   80100608 <panic>
  if(ip->type == T_DIR){
8010620a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620d:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106211:	66 83 f8 01          	cmp    $0x1,%ax
80106215:	75 21                	jne    80106238 <sys_unlink+0x183>
    dp->nlink--;
80106217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621a:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010621e:	83 e8 01             	sub    $0x1,%eax
80106221:	89 c2                	mov    %eax,%edx
80106223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106226:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
8010622a:	83 ec 0c             	sub    $0xc,%esp
8010622d:	ff 75 f4             	pushl  -0xc(%ebp)
80106230:	e8 5e b7 ff ff       	call   80101993 <iupdate>
80106235:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106238:	83 ec 0c             	sub    $0xc,%esp
8010623b:	ff 75 f4             	pushl  -0xc(%ebp)
8010623e:	e8 76 bb ff ff       	call   80101db9 <iunlockput>
80106243:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106249:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010624d:	83 e8 01             	sub    $0x1,%eax
80106250:	89 c2                	mov    %eax,%edx
80106252:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106255:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106259:	83 ec 0c             	sub    $0xc,%esp
8010625c:	ff 75 f0             	pushl  -0x10(%ebp)
8010625f:	e8 2f b7 ff ff       	call   80101993 <iupdate>
80106264:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106267:	83 ec 0c             	sub    $0xc,%esp
8010626a:	ff 75 f0             	pushl  -0x10(%ebp)
8010626d:	e8 47 bb ff ff       	call   80101db9 <iunlockput>
80106272:	83 c4 10             	add    $0x10,%esp

  end_op();
80106275:	e8 87 d5 ff ff       	call   80103801 <end_op>

  return 0;
8010627a:	b8 00 00 00 00       	mov    $0x0,%eax
8010627f:	eb 1c                	jmp    8010629d <sys_unlink+0x1e8>
    goto bad;
80106281:	90                   	nop
80106282:	eb 01                	jmp    80106285 <sys_unlink+0x1d0>
    goto bad;
80106284:	90                   	nop

bad:
  iunlockput(dp);
80106285:	83 ec 0c             	sub    $0xc,%esp
80106288:	ff 75 f4             	pushl  -0xc(%ebp)
8010628b:	e8 29 bb ff ff       	call   80101db9 <iunlockput>
80106290:	83 c4 10             	add    $0x10,%esp
  end_op();
80106293:	e8 69 d5 ff ff       	call   80103801 <end_op>
  return -1;
80106298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010629d:	c9                   	leave  
8010629e:	c3                   	ret    

8010629f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010629f:	f3 0f 1e fb          	endbr32 
801062a3:	55                   	push   %ebp
801062a4:	89 e5                	mov    %esp,%ebp
801062a6:	83 ec 38             	sub    $0x38,%esp
801062a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801062ac:	8b 55 10             	mov    0x10(%ebp),%edx
801062af:	8b 45 14             	mov    0x14(%ebp),%eax
801062b2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801062b6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801062ba:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801062be:	83 ec 08             	sub    $0x8,%esp
801062c1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801062c4:	50                   	push   %eax
801062c5:	ff 75 08             	pushl  0x8(%ebp)
801062c8:	e8 3a c4 ff ff       	call   80102707 <nameiparent>
801062cd:	83 c4 10             	add    $0x10,%esp
801062d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062d3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d7:	75 0a                	jne    801062e3 <create+0x44>
    return 0;
801062d9:	b8 00 00 00 00       	mov    $0x0,%eax
801062de:	e9 8e 01 00 00       	jmp    80106471 <create+0x1d2>
  ilock(dp);
801062e3:	83 ec 0c             	sub    $0xc,%esp
801062e6:	ff 75 f4             	pushl  -0xc(%ebp)
801062e9:	e8 8e b8 ff ff       	call   80101b7c <ilock>
801062ee:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
801062f1:	83 ec 04             	sub    $0x4,%esp
801062f4:	6a 00                	push   $0x0
801062f6:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801062f9:	50                   	push   %eax
801062fa:	ff 75 f4             	pushl  -0xc(%ebp)
801062fd:	e8 84 c0 ff ff       	call   80102386 <dirlookup>
80106302:	83 c4 10             	add    $0x10,%esp
80106305:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106308:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010630c:	74 50                	je     8010635e <create+0xbf>
    iunlockput(dp);
8010630e:	83 ec 0c             	sub    $0xc,%esp
80106311:	ff 75 f4             	pushl  -0xc(%ebp)
80106314:	e8 a0 ba ff ff       	call   80101db9 <iunlockput>
80106319:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010631c:	83 ec 0c             	sub    $0xc,%esp
8010631f:	ff 75 f0             	pushl  -0x10(%ebp)
80106322:	e8 55 b8 ff ff       	call   80101b7c <ilock>
80106327:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010632a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010632f:	75 15                	jne    80106346 <create+0xa7>
80106331:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106334:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106338:	66 83 f8 02          	cmp    $0x2,%ax
8010633c:	75 08                	jne    80106346 <create+0xa7>
      return ip;
8010633e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106341:	e9 2b 01 00 00       	jmp    80106471 <create+0x1d2>
    iunlockput(ip);
80106346:	83 ec 0c             	sub    $0xc,%esp
80106349:	ff 75 f0             	pushl  -0x10(%ebp)
8010634c:	e8 68 ba ff ff       	call   80101db9 <iunlockput>
80106351:	83 c4 10             	add    $0x10,%esp
    return 0;
80106354:	b8 00 00 00 00       	mov    $0x0,%eax
80106359:	e9 13 01 00 00       	jmp    80106471 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010635e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106362:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106365:	8b 00                	mov    (%eax),%eax
80106367:	83 ec 08             	sub    $0x8,%esp
8010636a:	52                   	push   %edx
8010636b:	50                   	push   %eax
8010636c:	e8 47 b5 ff ff       	call   801018b8 <ialloc>
80106371:	83 c4 10             	add    $0x10,%esp
80106374:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106377:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010637b:	75 0d                	jne    8010638a <create+0xeb>
    panic("create: ialloc");
8010637d:	83 ec 0c             	sub    $0xc,%esp
80106380:	68 7c 9b 10 80       	push   $0x80109b7c
80106385:	e8 7e a2 ff ff       	call   80100608 <panic>

  ilock(ip);
8010638a:	83 ec 0c             	sub    $0xc,%esp
8010638d:	ff 75 f0             	pushl  -0x10(%ebp)
80106390:	e8 e7 b7 ff ff       	call   80101b7c <ilock>
80106395:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010639f:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
801063a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801063aa:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801063ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b1:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801063b7:	83 ec 0c             	sub    $0xc,%esp
801063ba:	ff 75 f0             	pushl  -0x10(%ebp)
801063bd:	e8 d1 b5 ff ff       	call   80101993 <iupdate>
801063c2:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801063c5:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801063ca:	75 6a                	jne    80106436 <create+0x197>
    dp->nlink++;  // for ".."
801063cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063cf:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801063d3:	83 c0 01             	add    $0x1,%eax
801063d6:	89 c2                	mov    %eax,%edx
801063d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063db:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801063df:	83 ec 0c             	sub    $0xc,%esp
801063e2:	ff 75 f4             	pushl  -0xc(%ebp)
801063e5:	e8 a9 b5 ff ff       	call   80101993 <iupdate>
801063ea:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801063ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f0:	8b 40 04             	mov    0x4(%eax),%eax
801063f3:	83 ec 04             	sub    $0x4,%esp
801063f6:	50                   	push   %eax
801063f7:	68 56 9b 10 80       	push   $0x80109b56
801063fc:	ff 75 f0             	pushl  -0x10(%ebp)
801063ff:	e8 40 c0 ff ff       	call   80102444 <dirlink>
80106404:	83 c4 10             	add    $0x10,%esp
80106407:	85 c0                	test   %eax,%eax
80106409:	78 1e                	js     80106429 <create+0x18a>
8010640b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640e:	8b 40 04             	mov    0x4(%eax),%eax
80106411:	83 ec 04             	sub    $0x4,%esp
80106414:	50                   	push   %eax
80106415:	68 58 9b 10 80       	push   $0x80109b58
8010641a:	ff 75 f0             	pushl  -0x10(%ebp)
8010641d:	e8 22 c0 ff ff       	call   80102444 <dirlink>
80106422:	83 c4 10             	add    $0x10,%esp
80106425:	85 c0                	test   %eax,%eax
80106427:	79 0d                	jns    80106436 <create+0x197>
      panic("create dots");
80106429:	83 ec 0c             	sub    $0xc,%esp
8010642c:	68 8b 9b 10 80       	push   $0x80109b8b
80106431:	e8 d2 a1 ff ff       	call   80100608 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106436:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106439:	8b 40 04             	mov    0x4(%eax),%eax
8010643c:	83 ec 04             	sub    $0x4,%esp
8010643f:	50                   	push   %eax
80106440:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106443:	50                   	push   %eax
80106444:	ff 75 f4             	pushl  -0xc(%ebp)
80106447:	e8 f8 bf ff ff       	call   80102444 <dirlink>
8010644c:	83 c4 10             	add    $0x10,%esp
8010644f:	85 c0                	test   %eax,%eax
80106451:	79 0d                	jns    80106460 <create+0x1c1>
    panic("create: dirlink");
80106453:	83 ec 0c             	sub    $0xc,%esp
80106456:	68 97 9b 10 80       	push   $0x80109b97
8010645b:	e8 a8 a1 ff ff       	call   80100608 <panic>

  iunlockput(dp);
80106460:	83 ec 0c             	sub    $0xc,%esp
80106463:	ff 75 f4             	pushl  -0xc(%ebp)
80106466:	e8 4e b9 ff ff       	call   80101db9 <iunlockput>
8010646b:	83 c4 10             	add    $0x10,%esp

  return ip;
8010646e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106471:	c9                   	leave  
80106472:	c3                   	ret    

80106473 <sys_open>:

int
sys_open(void)
{
80106473:	f3 0f 1e fb          	endbr32 
80106477:	55                   	push   %ebp
80106478:	89 e5                	mov    %esp,%ebp
8010647a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010647d:	83 ec 08             	sub    $0x8,%esp
80106480:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106483:	50                   	push   %eax
80106484:	6a 00                	push   $0x0
80106486:	e8 b4 f6 ff ff       	call   80105b3f <argstr>
8010648b:	83 c4 10             	add    $0x10,%esp
8010648e:	85 c0                	test   %eax,%eax
80106490:	78 15                	js     801064a7 <sys_open+0x34>
80106492:	83 ec 08             	sub    $0x8,%esp
80106495:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106498:	50                   	push   %eax
80106499:	6a 01                	push   $0x1
8010649b:	e8 02 f6 ff ff       	call   80105aa2 <argint>
801064a0:	83 c4 10             	add    $0x10,%esp
801064a3:	85 c0                	test   %eax,%eax
801064a5:	79 0a                	jns    801064b1 <sys_open+0x3e>
    return -1;
801064a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ac:	e9 61 01 00 00       	jmp    80106612 <sys_open+0x19f>

  begin_op();
801064b1:	e8 bb d2 ff ff       	call   80103771 <begin_op>

  if(omode & O_CREATE){
801064b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b9:	25 00 02 00 00       	and    $0x200,%eax
801064be:	85 c0                	test   %eax,%eax
801064c0:	74 2a                	je     801064ec <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801064c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064c5:	6a 00                	push   $0x0
801064c7:	6a 00                	push   $0x0
801064c9:	6a 02                	push   $0x2
801064cb:	50                   	push   %eax
801064cc:	e8 ce fd ff ff       	call   8010629f <create>
801064d1:	83 c4 10             	add    $0x10,%esp
801064d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801064d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064db:	75 75                	jne    80106552 <sys_open+0xdf>
      end_op();
801064dd:	e8 1f d3 ff ff       	call   80103801 <end_op>
      return -1;
801064e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e7:	e9 26 01 00 00       	jmp    80106612 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801064ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064ef:	83 ec 0c             	sub    $0xc,%esp
801064f2:	50                   	push   %eax
801064f3:	e8 ef c1 ff ff       	call   801026e7 <namei>
801064f8:	83 c4 10             	add    $0x10,%esp
801064fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106502:	75 0f                	jne    80106513 <sys_open+0xa0>
      end_op();
80106504:	e8 f8 d2 ff ff       	call   80103801 <end_op>
      return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	e9 ff 00 00 00       	jmp    80106612 <sys_open+0x19f>
    }
    ilock(ip);
80106513:	83 ec 0c             	sub    $0xc,%esp
80106516:	ff 75 f4             	pushl  -0xc(%ebp)
80106519:	e8 5e b6 ff ff       	call   80101b7c <ilock>
8010651e:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106524:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106528:	66 83 f8 01          	cmp    $0x1,%ax
8010652c:	75 24                	jne    80106552 <sys_open+0xdf>
8010652e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106531:	85 c0                	test   %eax,%eax
80106533:	74 1d                	je     80106552 <sys_open+0xdf>
      iunlockput(ip);
80106535:	83 ec 0c             	sub    $0xc,%esp
80106538:	ff 75 f4             	pushl  -0xc(%ebp)
8010653b:	e8 79 b8 ff ff       	call   80101db9 <iunlockput>
80106540:	83 c4 10             	add    $0x10,%esp
      end_op();
80106543:	e8 b9 d2 ff ff       	call   80103801 <end_op>
      return -1;
80106548:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654d:	e9 c0 00 00 00       	jmp    80106612 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106552:	e8 df ab ff ff       	call   80101136 <filealloc>
80106557:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010655a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010655e:	74 17                	je     80106577 <sys_open+0x104>
80106560:	83 ec 0c             	sub    $0xc,%esp
80106563:	ff 75 f0             	pushl  -0x10(%ebp)
80106566:	e8 09 f7 ff ff       	call   80105c74 <fdalloc>
8010656b:	83 c4 10             	add    $0x10,%esp
8010656e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106571:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106575:	79 2e                	jns    801065a5 <sys_open+0x132>
    if(f)
80106577:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657b:	74 0e                	je     8010658b <sys_open+0x118>
      fileclose(f);
8010657d:	83 ec 0c             	sub    $0xc,%esp
80106580:	ff 75 f0             	pushl  -0x10(%ebp)
80106583:	e8 74 ac ff ff       	call   801011fc <fileclose>
80106588:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010658b:	83 ec 0c             	sub    $0xc,%esp
8010658e:	ff 75 f4             	pushl  -0xc(%ebp)
80106591:	e8 23 b8 ff ff       	call   80101db9 <iunlockput>
80106596:	83 c4 10             	add    $0x10,%esp
    end_op();
80106599:	e8 63 d2 ff ff       	call   80103801 <end_op>
    return -1;
8010659e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a3:	eb 6d                	jmp    80106612 <sys_open+0x19f>
  }
  iunlock(ip);
801065a5:	83 ec 0c             	sub    $0xc,%esp
801065a8:	ff 75 f4             	pushl  -0xc(%ebp)
801065ab:	e8 e3 b6 ff ff       	call   80101c93 <iunlock>
801065b0:	83 c4 10             	add    $0x10,%esp
  end_op();
801065b3:	e8 49 d2 ff ff       	call   80103801 <end_op>

  f->type = FD_INODE;
801065b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065bb:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801065c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065c7:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801065ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065cd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801065d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065d7:	83 e0 01             	and    $0x1,%eax
801065da:	85 c0                	test   %eax,%eax
801065dc:	0f 94 c0             	sete   %al
801065df:	89 c2                	mov    %eax,%edx
801065e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e4:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801065e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ea:	83 e0 01             	and    $0x1,%eax
801065ed:	85 c0                	test   %eax,%eax
801065ef:	75 0a                	jne    801065fb <sys_open+0x188>
801065f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065f4:	83 e0 02             	and    $0x2,%eax
801065f7:	85 c0                	test   %eax,%eax
801065f9:	74 07                	je     80106602 <sys_open+0x18f>
801065fb:	b8 01 00 00 00       	mov    $0x1,%eax
80106600:	eb 05                	jmp    80106607 <sys_open+0x194>
80106602:	b8 00 00 00 00       	mov    $0x0,%eax
80106607:	89 c2                	mov    %eax,%edx
80106609:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010660c:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010660f:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106612:	c9                   	leave  
80106613:	c3                   	ret    

80106614 <sys_mkdir>:

int
sys_mkdir(void)
{
80106614:	f3 0f 1e fb          	endbr32 
80106618:	55                   	push   %ebp
80106619:	89 e5                	mov    %esp,%ebp
8010661b:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010661e:	e8 4e d1 ff ff       	call   80103771 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106623:	83 ec 08             	sub    $0x8,%esp
80106626:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106629:	50                   	push   %eax
8010662a:	6a 00                	push   $0x0
8010662c:	e8 0e f5 ff ff       	call   80105b3f <argstr>
80106631:	83 c4 10             	add    $0x10,%esp
80106634:	85 c0                	test   %eax,%eax
80106636:	78 1b                	js     80106653 <sys_mkdir+0x3f>
80106638:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010663b:	6a 00                	push   $0x0
8010663d:	6a 00                	push   $0x0
8010663f:	6a 01                	push   $0x1
80106641:	50                   	push   %eax
80106642:	e8 58 fc ff ff       	call   8010629f <create>
80106647:	83 c4 10             	add    $0x10,%esp
8010664a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010664d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106651:	75 0c                	jne    8010665f <sys_mkdir+0x4b>
    end_op();
80106653:	e8 a9 d1 ff ff       	call   80103801 <end_op>
    return -1;
80106658:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665d:	eb 18                	jmp    80106677 <sys_mkdir+0x63>
  }
  iunlockput(ip);
8010665f:	83 ec 0c             	sub    $0xc,%esp
80106662:	ff 75 f4             	pushl  -0xc(%ebp)
80106665:	e8 4f b7 ff ff       	call   80101db9 <iunlockput>
8010666a:	83 c4 10             	add    $0x10,%esp
  end_op();
8010666d:	e8 8f d1 ff ff       	call   80103801 <end_op>
  return 0;
80106672:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106677:	c9                   	leave  
80106678:	c3                   	ret    

80106679 <sys_mknod>:

int
sys_mknod(void)
{
80106679:	f3 0f 1e fb          	endbr32 
8010667d:	55                   	push   %ebp
8010667e:	89 e5                	mov    %esp,%ebp
80106680:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106683:	e8 e9 d0 ff ff       	call   80103771 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106688:	83 ec 08             	sub    $0x8,%esp
8010668b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010668e:	50                   	push   %eax
8010668f:	6a 00                	push   $0x0
80106691:	e8 a9 f4 ff ff       	call   80105b3f <argstr>
80106696:	83 c4 10             	add    $0x10,%esp
80106699:	85 c0                	test   %eax,%eax
8010669b:	78 4f                	js     801066ec <sys_mknod+0x73>
     argint(1, &major) < 0 ||
8010669d:	83 ec 08             	sub    $0x8,%esp
801066a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066a3:	50                   	push   %eax
801066a4:	6a 01                	push   $0x1
801066a6:	e8 f7 f3 ff ff       	call   80105aa2 <argint>
801066ab:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801066ae:	85 c0                	test   %eax,%eax
801066b0:	78 3a                	js     801066ec <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801066b2:	83 ec 08             	sub    $0x8,%esp
801066b5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066b8:	50                   	push   %eax
801066b9:	6a 02                	push   $0x2
801066bb:	e8 e2 f3 ff ff       	call   80105aa2 <argint>
801066c0:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801066c3:	85 c0                	test   %eax,%eax
801066c5:	78 25                	js     801066ec <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801066c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066ca:	0f bf c8             	movswl %ax,%ecx
801066cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066d0:	0f bf d0             	movswl %ax,%edx
801066d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d6:	51                   	push   %ecx
801066d7:	52                   	push   %edx
801066d8:	6a 03                	push   $0x3
801066da:	50                   	push   %eax
801066db:	e8 bf fb ff ff       	call   8010629f <create>
801066e0:	83 c4 10             	add    $0x10,%esp
801066e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801066e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ea:	75 0c                	jne    801066f8 <sys_mknod+0x7f>
    end_op();
801066ec:	e8 10 d1 ff ff       	call   80103801 <end_op>
    return -1;
801066f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f6:	eb 18                	jmp    80106710 <sys_mknod+0x97>
  }
  iunlockput(ip);
801066f8:	83 ec 0c             	sub    $0xc,%esp
801066fb:	ff 75 f4             	pushl  -0xc(%ebp)
801066fe:	e8 b6 b6 ff ff       	call   80101db9 <iunlockput>
80106703:	83 c4 10             	add    $0x10,%esp
  end_op();
80106706:	e8 f6 d0 ff ff       	call   80103801 <end_op>
  return 0;
8010670b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106710:	c9                   	leave  
80106711:	c3                   	ret    

80106712 <sys_chdir>:

int
sys_chdir(void)
{
80106712:	f3 0f 1e fb          	endbr32 
80106716:	55                   	push   %ebp
80106717:	89 e5                	mov    %esp,%ebp
80106719:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010671c:	e8 0f de ff ff       	call   80104530 <myproc>
80106721:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106724:	e8 48 d0 ff ff       	call   80103771 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106729:	83 ec 08             	sub    $0x8,%esp
8010672c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010672f:	50                   	push   %eax
80106730:	6a 00                	push   $0x0
80106732:	e8 08 f4 ff ff       	call   80105b3f <argstr>
80106737:	83 c4 10             	add    $0x10,%esp
8010673a:	85 c0                	test   %eax,%eax
8010673c:	78 18                	js     80106756 <sys_chdir+0x44>
8010673e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106741:	83 ec 0c             	sub    $0xc,%esp
80106744:	50                   	push   %eax
80106745:	e8 9d bf ff ff       	call   801026e7 <namei>
8010674a:	83 c4 10             	add    $0x10,%esp
8010674d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106750:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106754:	75 0c                	jne    80106762 <sys_chdir+0x50>
    end_op();
80106756:	e8 a6 d0 ff ff       	call   80103801 <end_op>
    return -1;
8010675b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106760:	eb 68                	jmp    801067ca <sys_chdir+0xb8>
  }
  ilock(ip);
80106762:	83 ec 0c             	sub    $0xc,%esp
80106765:	ff 75 f0             	pushl  -0x10(%ebp)
80106768:	e8 0f b4 ff ff       	call   80101b7c <ilock>
8010676d:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106773:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106777:	66 83 f8 01          	cmp    $0x1,%ax
8010677b:	74 1a                	je     80106797 <sys_chdir+0x85>
    iunlockput(ip);
8010677d:	83 ec 0c             	sub    $0xc,%esp
80106780:	ff 75 f0             	pushl  -0x10(%ebp)
80106783:	e8 31 b6 ff ff       	call   80101db9 <iunlockput>
80106788:	83 c4 10             	add    $0x10,%esp
    end_op();
8010678b:	e8 71 d0 ff ff       	call   80103801 <end_op>
    return -1;
80106790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106795:	eb 33                	jmp    801067ca <sys_chdir+0xb8>
  }
  iunlock(ip);
80106797:	83 ec 0c             	sub    $0xc,%esp
8010679a:	ff 75 f0             	pushl  -0x10(%ebp)
8010679d:	e8 f1 b4 ff ff       	call   80101c93 <iunlock>
801067a2:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
801067a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a8:	8b 40 68             	mov    0x68(%eax),%eax
801067ab:	83 ec 0c             	sub    $0xc,%esp
801067ae:	50                   	push   %eax
801067af:	e8 31 b5 ff ff       	call   80101ce5 <iput>
801067b4:	83 c4 10             	add    $0x10,%esp
  end_op();
801067b7:	e8 45 d0 ff ff       	call   80103801 <end_op>
  curproc->cwd = ip;
801067bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067c2:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801067c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067ca:	c9                   	leave  
801067cb:	c3                   	ret    

801067cc <sys_exec>:

int
sys_exec(void)
{
801067cc:	f3 0f 1e fb          	endbr32 
801067d0:	55                   	push   %ebp
801067d1:	89 e5                	mov    %esp,%ebp
801067d3:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801067d9:	83 ec 08             	sub    $0x8,%esp
801067dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067df:	50                   	push   %eax
801067e0:	6a 00                	push   $0x0
801067e2:	e8 58 f3 ff ff       	call   80105b3f <argstr>
801067e7:	83 c4 10             	add    $0x10,%esp
801067ea:	85 c0                	test   %eax,%eax
801067ec:	78 18                	js     80106806 <sys_exec+0x3a>
801067ee:	83 ec 08             	sub    $0x8,%esp
801067f1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801067f7:	50                   	push   %eax
801067f8:	6a 01                	push   $0x1
801067fa:	e8 a3 f2 ff ff       	call   80105aa2 <argint>
801067ff:	83 c4 10             	add    $0x10,%esp
80106802:	85 c0                	test   %eax,%eax
80106804:	79 0a                	jns    80106810 <sys_exec+0x44>
    return -1;
80106806:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010680b:	e9 c6 00 00 00       	jmp    801068d6 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106810:	83 ec 04             	sub    $0x4,%esp
80106813:	68 80 00 00 00       	push   $0x80
80106818:	6a 00                	push   $0x0
8010681a:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106820:	50                   	push   %eax
80106821:	e8 28 ef ff ff       	call   8010574e <memset>
80106826:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106829:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106833:	83 f8 1f             	cmp    $0x1f,%eax
80106836:	76 0a                	jbe    80106842 <sys_exec+0x76>
      return -1;
80106838:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010683d:	e9 94 00 00 00       	jmp    801068d6 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106845:	c1 e0 02             	shl    $0x2,%eax
80106848:	89 c2                	mov    %eax,%edx
8010684a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106850:	01 c2                	add    %eax,%edx
80106852:	83 ec 08             	sub    $0x8,%esp
80106855:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010685b:	50                   	push   %eax
8010685c:	52                   	push   %edx
8010685d:	e8 95 f1 ff ff       	call   801059f7 <fetchint>
80106862:	83 c4 10             	add    $0x10,%esp
80106865:	85 c0                	test   %eax,%eax
80106867:	79 07                	jns    80106870 <sys_exec+0xa4>
      return -1;
80106869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686e:	eb 66                	jmp    801068d6 <sys_exec+0x10a>
    if(uarg == 0){
80106870:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106876:	85 c0                	test   %eax,%eax
80106878:	75 27                	jne    801068a1 <sys_exec+0xd5>
      argv[i] = 0;
8010687a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010687d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106884:	00 00 00 00 
      break;
80106888:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010688c:	83 ec 08             	sub    $0x8,%esp
8010688f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106895:	52                   	push   %edx
80106896:	50                   	push   %eax
80106897:	e8 94 a3 ff ff       	call   80100c30 <exec>
8010689c:	83 c4 10             	add    $0x10,%esp
8010689f:	eb 35                	jmp    801068d6 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801068a1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801068a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068aa:	c1 e2 02             	shl    $0x2,%edx
801068ad:	01 c2                	add    %eax,%edx
801068af:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068b5:	83 ec 08             	sub    $0x8,%esp
801068b8:	52                   	push   %edx
801068b9:	50                   	push   %eax
801068ba:	e8 7b f1 ff ff       	call   80105a3a <fetchstr>
801068bf:	83 c4 10             	add    $0x10,%esp
801068c2:	85 c0                	test   %eax,%eax
801068c4:	79 07                	jns    801068cd <sys_exec+0x101>
      return -1;
801068c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cb:	eb 09                	jmp    801068d6 <sys_exec+0x10a>
  for(i=0;; i++){
801068cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801068d1:	e9 5a ff ff ff       	jmp    80106830 <sys_exec+0x64>
}
801068d6:	c9                   	leave  
801068d7:	c3                   	ret    

801068d8 <sys_pipe>:

int
sys_pipe(void)
{
801068d8:	f3 0f 1e fb          	endbr32 
801068dc:	55                   	push   %ebp
801068dd:	89 e5                	mov    %esp,%ebp
801068df:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801068e2:	83 ec 04             	sub    $0x4,%esp
801068e5:	6a 08                	push   $0x8
801068e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068ea:	50                   	push   %eax
801068eb:	6a 00                	push   $0x0
801068ed:	e8 e1 f1 ff ff       	call   80105ad3 <argptr>
801068f2:	83 c4 10             	add    $0x10,%esp
801068f5:	85 c0                	test   %eax,%eax
801068f7:	79 0a                	jns    80106903 <sys_pipe+0x2b>
    return -1;
801068f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068fe:	e9 ae 00 00 00       	jmp    801069b1 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
80106903:	83 ec 08             	sub    $0x8,%esp
80106906:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106909:	50                   	push   %eax
8010690a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010690d:	50                   	push   %eax
8010690e:	e8 3e d7 ff ff       	call   80104051 <pipealloc>
80106913:	83 c4 10             	add    $0x10,%esp
80106916:	85 c0                	test   %eax,%eax
80106918:	79 0a                	jns    80106924 <sys_pipe+0x4c>
    return -1;
8010691a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010691f:	e9 8d 00 00 00       	jmp    801069b1 <sys_pipe+0xd9>
  fd0 = -1;
80106924:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010692b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010692e:	83 ec 0c             	sub    $0xc,%esp
80106931:	50                   	push   %eax
80106932:	e8 3d f3 ff ff       	call   80105c74 <fdalloc>
80106937:	83 c4 10             	add    $0x10,%esp
8010693a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010693d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106941:	78 18                	js     8010695b <sys_pipe+0x83>
80106943:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106946:	83 ec 0c             	sub    $0xc,%esp
80106949:	50                   	push   %eax
8010694a:	e8 25 f3 ff ff       	call   80105c74 <fdalloc>
8010694f:	83 c4 10             	add    $0x10,%esp
80106952:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106955:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106959:	79 3e                	jns    80106999 <sys_pipe+0xc1>
    if(fd0 >= 0)
8010695b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010695f:	78 13                	js     80106974 <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106961:	e8 ca db ff ff       	call   80104530 <myproc>
80106966:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106969:	83 c2 08             	add    $0x8,%edx
8010696c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106973:	00 
    fileclose(rf);
80106974:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106977:	83 ec 0c             	sub    $0xc,%esp
8010697a:	50                   	push   %eax
8010697b:	e8 7c a8 ff ff       	call   801011fc <fileclose>
80106980:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106986:	83 ec 0c             	sub    $0xc,%esp
80106989:	50                   	push   %eax
8010698a:	e8 6d a8 ff ff       	call   801011fc <fileclose>
8010698f:	83 c4 10             	add    $0x10,%esp
    return -1;
80106992:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106997:	eb 18                	jmp    801069b1 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106999:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010699c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010699f:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801069a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069a4:	8d 50 04             	lea    0x4(%eax),%edx
801069a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069aa:	89 02                	mov    %eax,(%edx)
  return 0;
801069ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069b1:	c9                   	leave  
801069b2:	c3                   	ret    

801069b3 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801069b3:	f3 0f 1e fb          	endbr32 
801069b7:	55                   	push   %ebp
801069b8:	89 e5                	mov    %esp,%ebp
801069ba:	83 ec 08             	sub    $0x8,%esp
  return fork();
801069bd:	e8 77 e0 ff ff       	call   80104a39 <fork>
}
801069c2:	c9                   	leave  
801069c3:	c3                   	ret    

801069c4 <sys_exit>:

int
sys_exit(void)
{
801069c4:	f3 0f 1e fb          	endbr32 
801069c8:	55                   	push   %ebp
801069c9:	89 e5                	mov    %esp,%ebp
801069cb:	83 ec 08             	sub    $0x8,%esp
  exit();
801069ce:	e8 18 e2 ff ff       	call   80104beb <exit>
  return 0;  // not reached
801069d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069d8:	c9                   	leave  
801069d9:	c3                   	ret    

801069da <sys_wait>:

int
sys_wait(void)
{
801069da:	f3 0f 1e fb          	endbr32 
801069de:	55                   	push   %ebp
801069df:	89 e5                	mov    %esp,%ebp
801069e1:	83 ec 08             	sub    $0x8,%esp
  return wait();
801069e4:	e8 29 e3 ff ff       	call   80104d12 <wait>
}
801069e9:	c9                   	leave  
801069ea:	c3                   	ret    

801069eb <sys_kill>:

int
sys_kill(void)
{
801069eb:	f3 0f 1e fb          	endbr32 
801069ef:	55                   	push   %ebp
801069f0:	89 e5                	mov    %esp,%ebp
801069f2:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801069f5:	83 ec 08             	sub    $0x8,%esp
801069f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069fb:	50                   	push   %eax
801069fc:	6a 00                	push   $0x0
801069fe:	e8 9f f0 ff ff       	call   80105aa2 <argint>
80106a03:	83 c4 10             	add    $0x10,%esp
80106a06:	85 c0                	test   %eax,%eax
80106a08:	79 07                	jns    80106a11 <sys_kill+0x26>
    return -1;
80106a0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a0f:	eb 0f                	jmp    80106a20 <sys_kill+0x35>
  return kill(pid);
80106a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a14:	83 ec 0c             	sub    $0xc,%esp
80106a17:	50                   	push   %eax
80106a18:	e8 4d e7 ff ff       	call   8010516a <kill>
80106a1d:	83 c4 10             	add    $0x10,%esp
}
80106a20:	c9                   	leave  
80106a21:	c3                   	ret    

80106a22 <sys_getpid>:

int
sys_getpid(void)
{
80106a22:	f3 0f 1e fb          	endbr32 
80106a26:	55                   	push   %ebp
80106a27:	89 e5                	mov    %esp,%ebp
80106a29:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106a2c:	e8 ff da ff ff       	call   80104530 <myproc>
80106a31:	8b 40 10             	mov    0x10(%eax),%eax
}
80106a34:	c9                   	leave  
80106a35:	c3                   	ret    

80106a36 <sys_sbrk>:

int
sys_sbrk(void)
{
80106a36:	f3 0f 1e fb          	endbr32 
80106a3a:	55                   	push   %ebp
80106a3b:	89 e5                	mov    %esp,%ebp
80106a3d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106a40:	83 ec 08             	sub    $0x8,%esp
80106a43:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a46:	50                   	push   %eax
80106a47:	6a 00                	push   $0x0
80106a49:	e8 54 f0 ff ff       	call   80105aa2 <argint>
80106a4e:	83 c4 10             	add    $0x10,%esp
80106a51:	85 c0                	test   %eax,%eax
80106a53:	79 07                	jns    80106a5c <sys_sbrk+0x26>
    return -1;
80106a55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a5a:	eb 27                	jmp    80106a83 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106a5c:	e8 cf da ff ff       	call   80104530 <myproc>
80106a61:	8b 00                	mov    (%eax),%eax
80106a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a69:	83 ec 0c             	sub    $0xc,%esp
80106a6c:	50                   	push   %eax
80106a6d:	e8 76 dd ff ff       	call   801047e8 <growproc>
80106a72:	83 c4 10             	add    $0x10,%esp
80106a75:	85 c0                	test   %eax,%eax
80106a77:	79 07                	jns    80106a80 <sys_sbrk+0x4a>
    return -1;
80106a79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a7e:	eb 03                	jmp    80106a83 <sys_sbrk+0x4d>
  return addr;
80106a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a83:	c9                   	leave  
80106a84:	c3                   	ret    

80106a85 <sys_sleep>:

int
sys_sleep(void)
{
80106a85:	f3 0f 1e fb          	endbr32 
80106a89:	55                   	push   %ebp
80106a8a:	89 e5                	mov    %esp,%ebp
80106a8c:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106a8f:	83 ec 08             	sub    $0x8,%esp
80106a92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a95:	50                   	push   %eax
80106a96:	6a 00                	push   $0x0
80106a98:	e8 05 f0 ff ff       	call   80105aa2 <argint>
80106a9d:	83 c4 10             	add    $0x10,%esp
80106aa0:	85 c0                	test   %eax,%eax
80106aa2:	79 07                	jns    80106aab <sys_sleep+0x26>
    return -1;
80106aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa9:	eb 76                	jmp    80106b21 <sys_sleep+0x9c>
  acquire(&tickslock);
80106aab:	83 ec 0c             	sub    $0xc,%esp
80106aae:	68 00 87 11 80       	push   $0x80118700
80106ab3:	e8 f7 e9 ff ff       	call   801054af <acquire>
80106ab8:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106abb:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106ac3:	eb 38                	jmp    80106afd <sys_sleep+0x78>
    if(myproc()->killed){
80106ac5:	e8 66 da ff ff       	call   80104530 <myproc>
80106aca:	8b 40 24             	mov    0x24(%eax),%eax
80106acd:	85 c0                	test   %eax,%eax
80106acf:	74 17                	je     80106ae8 <sys_sleep+0x63>
      release(&tickslock);
80106ad1:	83 ec 0c             	sub    $0xc,%esp
80106ad4:	68 00 87 11 80       	push   $0x80118700
80106ad9:	e8 43 ea ff ff       	call   80105521 <release>
80106ade:	83 c4 10             	add    $0x10,%esp
      return -1;
80106ae1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ae6:	eb 39                	jmp    80106b21 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106ae8:	83 ec 08             	sub    $0x8,%esp
80106aeb:	68 00 87 11 80       	push   $0x80118700
80106af0:	68 40 8f 11 80       	push   $0x80118f40
80106af5:	e8 43 e5 ff ff       	call   8010503d <sleep>
80106afa:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106afd:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106b02:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106b05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b08:	39 d0                	cmp    %edx,%eax
80106b0a:	72 b9                	jb     80106ac5 <sys_sleep+0x40>
  }
  release(&tickslock);
80106b0c:	83 ec 0c             	sub    $0xc,%esp
80106b0f:	68 00 87 11 80       	push   $0x80118700
80106b14:	e8 08 ea ff ff       	call   80105521 <release>
80106b19:	83 c4 10             	add    $0x10,%esp
  return 0;
80106b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b21:	c9                   	leave  
80106b22:	c3                   	ret    

80106b23 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106b23:	f3 0f 1e fb          	endbr32 
80106b27:	55                   	push   %ebp
80106b28:	89 e5                	mov    %esp,%ebp
80106b2a:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106b2d:	83 ec 0c             	sub    $0xc,%esp
80106b30:	68 00 87 11 80       	push   $0x80118700
80106b35:	e8 75 e9 ff ff       	call   801054af <acquire>
80106b3a:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106b3d:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106b45:	83 ec 0c             	sub    $0xc,%esp
80106b48:	68 00 87 11 80       	push   $0x80118700
80106b4d:	e8 cf e9 ff ff       	call   80105521 <release>
80106b52:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106b58:	c9                   	leave  
80106b59:	c3                   	ret    

80106b5a <sys_mencrypt>:

//changed: added wrapper here
int sys_mencrypt(void) {
80106b5a:	f3 0f 1e fb          	endbr32 
80106b5e:	55                   	push   %ebp
80106b5f:	89 e5                	mov    %esp,%ebp
80106b61:	83 ec 18             	sub    $0x18,%esp
  int len;
  char * virtual_addr;

  if(argint(1, &len) < 0)
80106b64:	83 ec 08             	sub    $0x8,%esp
80106b67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106b6a:	50                   	push   %eax
80106b6b:	6a 01                	push   $0x1
80106b6d:	e8 30 ef ff ff       	call   80105aa2 <argint>
80106b72:	83 c4 10             	add    $0x10,%esp
80106b75:	85 c0                	test   %eax,%eax
80106b77:	79 07                	jns    80106b80 <sys_mencrypt+0x26>
    return -1;
80106b79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b7e:	eb 50                	jmp    80106bd0 <sys_mencrypt+0x76>
  if (len <= 0) {
80106b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b83:	85 c0                	test   %eax,%eax
80106b85:	7f 07                	jg     80106b8e <sys_mencrypt+0x34>
    return -1;
80106b87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8c:	eb 42                	jmp    80106bd0 <sys_mencrypt+0x76>
  }
  if(argptr(0, &virtual_addr, 1) < 0)
80106b8e:	83 ec 04             	sub    $0x4,%esp
80106b91:	6a 01                	push   $0x1
80106b93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b96:	50                   	push   %eax
80106b97:	6a 00                	push   $0x0
80106b99:	e8 35 ef ff ff       	call   80105ad3 <argptr>
80106b9e:	83 c4 10             	add    $0x10,%esp
80106ba1:	85 c0                	test   %eax,%eax
80106ba3:	79 07                	jns    80106bac <sys_mencrypt+0x52>
    return -1;
80106ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106baa:	eb 24                	jmp    80106bd0 <sys_mencrypt+0x76>
  if ((void *) virtual_addr >= P2V(PHYSTOP)) {
80106bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106baf:	3d ff ff ff 8d       	cmp    $0x8dffffff,%eax
80106bb4:	76 07                	jbe    80106bbd <sys_mencrypt+0x63>
    return -1;
80106bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bbb:	eb 13                	jmp    80106bd0 <sys_mencrypt+0x76>
  }
  return mencrypt(virtual_addr, len);
80106bbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bc3:	83 ec 08             	sub    $0x8,%esp
80106bc6:	52                   	push   %edx
80106bc7:	50                   	push   %eax
80106bc8:	e8 29 24 00 00       	call   80108ff6 <mencrypt>
80106bcd:	83 c4 10             	add    $0x10,%esp
}
80106bd0:	c9                   	leave  
80106bd1:	c3                   	ret    

80106bd2 <sys_getpgtable>:

int sys_getpgtable(void) {
80106bd2:	f3 0f 1e fb          	endbr32 
80106bd6:	55                   	push   %ebp
80106bd7:	89 e5                	mov    %esp,%ebp
80106bd9:	83 ec 18             	sub    $0x18,%esp
  struct pt_entry * entries; 
  int num;
  int wsetOnly;

  if(argint(1, &num) < 0)
80106bdc:	83 ec 08             	sub    $0x8,%esp
80106bdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106be2:	50                   	push   %eax
80106be3:	6a 01                	push   $0x1
80106be5:	e8 b8 ee ff ff       	call   80105aa2 <argint>
80106bea:	83 c4 10             	add    $0x10,%esp
80106bed:	85 c0                	test   %eax,%eax
80106bef:	79 07                	jns    80106bf8 <sys_getpgtable+0x26>
    return -1;
80106bf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf6:	eb 56                	jmp    80106c4e <sys_getpgtable+0x7c>
  if(argint(2, &wsetOnly) < 0)
80106bf8:	83 ec 08             	sub    $0x8,%esp
80106bfb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106bfe:	50                   	push   %eax
80106bff:	6a 02                	push   $0x2
80106c01:	e8 9c ee ff ff       	call   80105aa2 <argint>
80106c06:	83 c4 10             	add    $0x10,%esp
80106c09:	85 c0                	test   %eax,%eax
80106c0b:	79 07                	jns    80106c14 <sys_getpgtable+0x42>
    return -1;
80106c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c12:	eb 3a                	jmp    80106c4e <sys_getpgtable+0x7c>
  if(argptr(0, (char**)&entries, num*sizeof(struct pt_entry)) < 0){
80106c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c17:	c1 e0 03             	shl    $0x3,%eax
80106c1a:	83 ec 04             	sub    $0x4,%esp
80106c1d:	50                   	push   %eax
80106c1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c21:	50                   	push   %eax
80106c22:	6a 00                	push   $0x0
80106c24:	e8 aa ee ff ff       	call   80105ad3 <argptr>
80106c29:	83 c4 10             	add    $0x10,%esp
80106c2c:	85 c0                	test   %eax,%eax
80106c2e:	79 07                	jns    80106c37 <sys_getpgtable+0x65>
    return -1;
80106c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c35:	eb 17                	jmp    80106c4e <sys_getpgtable+0x7c>
  }
  return getpgtable(entries, num, wsetOnly);
80106c37:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106c3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c40:	83 ec 04             	sub    $0x4,%esp
80106c43:	51                   	push   %ecx
80106c44:	52                   	push   %edx
80106c45:	50                   	push   %eax
80106c46:	e8 81 25 00 00       	call   801091cc <getpgtable>
80106c4b:	83 c4 10             	add    $0x10,%esp
}
80106c4e:	c9                   	leave  
80106c4f:	c3                   	ret    

80106c50 <sys_dump_rawphymem>:


int sys_dump_rawphymem(void) {
80106c50:	f3 0f 1e fb          	endbr32 
80106c54:	55                   	push   %ebp
80106c55:	89 e5                	mov    %esp,%ebp
80106c57:	83 ec 18             	sub    $0x18,%esp
  char * physical_addr; 
  char * buffer;

  if(argptr(1, &buffer, PGSIZE) < 0)
80106c5a:	83 ec 04             	sub    $0x4,%esp
80106c5d:	68 00 10 00 00       	push   $0x1000
80106c62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c65:	50                   	push   %eax
80106c66:	6a 01                	push   $0x1
80106c68:	e8 66 ee ff ff       	call   80105ad3 <argptr>
80106c6d:	83 c4 10             	add    $0x10,%esp
80106c70:	85 c0                	test   %eax,%eax
80106c72:	79 07                	jns    80106c7b <sys_dump_rawphymem+0x2b>
    return -1;
80106c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c79:	eb 2f                	jmp    80106caa <sys_dump_rawphymem+0x5a>
  if(argint(0, (int*)&physical_addr) < 0)
80106c7b:	83 ec 08             	sub    $0x8,%esp
80106c7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c81:	50                   	push   %eax
80106c82:	6a 00                	push   $0x0
80106c84:	e8 19 ee ff ff       	call   80105aa2 <argint>
80106c89:	83 c4 10             	add    $0x10,%esp
80106c8c:	85 c0                	test   %eax,%eax
80106c8e:	79 07                	jns    80106c97 <sys_dump_rawphymem+0x47>
    return -1;
80106c90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c95:	eb 13                	jmp    80106caa <sys_dump_rawphymem+0x5a>
  return dump_rawphymem((uint)physical_addr, buffer);
80106c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c9d:	83 ec 08             	sub    $0x8,%esp
80106ca0:	50                   	push   %eax
80106ca1:	52                   	push   %edx
80106ca2:	e8 ff 27 00 00       	call   801094a6 <dump_rawphymem>
80106ca7:	83 c4 10             	add    $0x10,%esp
}
80106caa:	c9                   	leave  
80106cab:	c3                   	ret    

80106cac <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106cac:	1e                   	push   %ds
  pushl %es
80106cad:	06                   	push   %es
  pushl %fs
80106cae:	0f a0                	push   %fs
  pushl %gs
80106cb0:	0f a8                	push   %gs
  pushal
80106cb2:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106cb3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106cb7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106cb9:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106cbb:	54                   	push   %esp
  call trap
80106cbc:	e8 df 01 00 00       	call   80106ea0 <trap>
  addl $4, %esp
80106cc1:	83 c4 04             	add    $0x4,%esp

80106cc4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106cc4:	61                   	popa   
  popl %gs
80106cc5:	0f a9                	pop    %gs
  popl %fs
80106cc7:	0f a1                	pop    %fs
  popl %es
80106cc9:	07                   	pop    %es
  popl %ds
80106cca:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ccb:	83 c4 08             	add    $0x8,%esp
  iret
80106cce:	cf                   	iret   

80106ccf <lidt>:
{
80106ccf:	55                   	push   %ebp
80106cd0:	89 e5                	mov    %esp,%ebp
80106cd2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cd8:	83 e8 01             	sub    $0x1,%eax
80106cdb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ce9:	c1 e8 10             	shr    $0x10,%eax
80106cec:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106cf0:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106cf3:	0f 01 18             	lidtl  (%eax)
}
80106cf6:	90                   	nop
80106cf7:	c9                   	leave  
80106cf8:	c3                   	ret    

80106cf9 <rcr2>:

static inline uint
rcr2(void)
{
80106cf9:	55                   	push   %ebp
80106cfa:	89 e5                	mov    %esp,%ebp
80106cfc:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106cff:	0f 20 d0             	mov    %cr2,%eax
80106d02:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106d05:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106d08:	c9                   	leave  
80106d09:	c3                   	ret    

80106d0a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106d0a:	f3 0f 1e fb          	endbr32 
80106d0e:	55                   	push   %ebp
80106d0f:	89 e5                	mov    %esp,%ebp
80106d11:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106d14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d1b:	e9 c3 00 00 00       	jmp    80106de3 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d23:	8b 04 85 84 d0 10 80 	mov    -0x7fef2f7c(,%eax,4),%eax
80106d2a:	89 c2                	mov    %eax,%edx
80106d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d2f:	66 89 14 c5 40 87 11 	mov    %dx,-0x7fee78c0(,%eax,8)
80106d36:	80 
80106d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d3a:	66 c7 04 c5 42 87 11 	movw   $0x8,-0x7fee78be(,%eax,8)
80106d41:	80 08 00 
80106d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d47:	0f b6 14 c5 44 87 11 	movzbl -0x7fee78bc(,%eax,8),%edx
80106d4e:	80 
80106d4f:	83 e2 e0             	and    $0xffffffe0,%edx
80106d52:	88 14 c5 44 87 11 80 	mov    %dl,-0x7fee78bc(,%eax,8)
80106d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d5c:	0f b6 14 c5 44 87 11 	movzbl -0x7fee78bc(,%eax,8),%edx
80106d63:	80 
80106d64:	83 e2 1f             	and    $0x1f,%edx
80106d67:	88 14 c5 44 87 11 80 	mov    %dl,-0x7fee78bc(,%eax,8)
80106d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d71:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106d78:	80 
80106d79:	83 e2 f0             	and    $0xfffffff0,%edx
80106d7c:	83 ca 0e             	or     $0xe,%edx
80106d7f:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d89:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106d90:	80 
80106d91:	83 e2 ef             	and    $0xffffffef,%edx
80106d94:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d9e:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106da5:	80 
80106da6:	83 e2 9f             	and    $0xffffff9f,%edx
80106da9:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106db3:	0f b6 14 c5 45 87 11 	movzbl -0x7fee78bb(,%eax,8),%edx
80106dba:	80 
80106dbb:	83 ca 80             	or     $0xffffff80,%edx
80106dbe:	88 14 c5 45 87 11 80 	mov    %dl,-0x7fee78bb(,%eax,8)
80106dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc8:	8b 04 85 84 d0 10 80 	mov    -0x7fef2f7c(,%eax,4),%eax
80106dcf:	c1 e8 10             	shr    $0x10,%eax
80106dd2:	89 c2                	mov    %eax,%edx
80106dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd7:	66 89 14 c5 46 87 11 	mov    %dx,-0x7fee78ba(,%eax,8)
80106dde:	80 
  for(i = 0; i < 256; i++)
80106ddf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106de3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106dea:	0f 8e 30 ff ff ff    	jle    80106d20 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106df0:	a1 84 d1 10 80       	mov    0x8010d184,%eax
80106df5:	66 a3 40 89 11 80    	mov    %ax,0x80118940
80106dfb:	66 c7 05 42 89 11 80 	movw   $0x8,0x80118942
80106e02:	08 00 
80106e04:	0f b6 05 44 89 11 80 	movzbl 0x80118944,%eax
80106e0b:	83 e0 e0             	and    $0xffffffe0,%eax
80106e0e:	a2 44 89 11 80       	mov    %al,0x80118944
80106e13:	0f b6 05 44 89 11 80 	movzbl 0x80118944,%eax
80106e1a:	83 e0 1f             	and    $0x1f,%eax
80106e1d:	a2 44 89 11 80       	mov    %al,0x80118944
80106e22:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e29:	83 c8 0f             	or     $0xf,%eax
80106e2c:	a2 45 89 11 80       	mov    %al,0x80118945
80106e31:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e38:	83 e0 ef             	and    $0xffffffef,%eax
80106e3b:	a2 45 89 11 80       	mov    %al,0x80118945
80106e40:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e47:	83 c8 60             	or     $0x60,%eax
80106e4a:	a2 45 89 11 80       	mov    %al,0x80118945
80106e4f:	0f b6 05 45 89 11 80 	movzbl 0x80118945,%eax
80106e56:	83 c8 80             	or     $0xffffff80,%eax
80106e59:	a2 45 89 11 80       	mov    %al,0x80118945
80106e5e:	a1 84 d1 10 80       	mov    0x8010d184,%eax
80106e63:	c1 e8 10             	shr    $0x10,%eax
80106e66:	66 a3 46 89 11 80    	mov    %ax,0x80118946

  initlock(&tickslock, "time");
80106e6c:	83 ec 08             	sub    $0x8,%esp
80106e6f:	68 a8 9b 10 80       	push   $0x80109ba8
80106e74:	68 00 87 11 80       	push   $0x80118700
80106e79:	e8 0b e6 ff ff       	call   80105489 <initlock>
80106e7e:	83 c4 10             	add    $0x10,%esp
}
80106e81:	90                   	nop
80106e82:	c9                   	leave  
80106e83:	c3                   	ret    

80106e84 <idtinit>:

void
idtinit(void)
{
80106e84:	f3 0f 1e fb          	endbr32 
80106e88:	55                   	push   %ebp
80106e89:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106e8b:	68 00 08 00 00       	push   $0x800
80106e90:	68 40 87 11 80       	push   $0x80118740
80106e95:	e8 35 fe ff ff       	call   80106ccf <lidt>
80106e9a:	83 c4 08             	add    $0x8,%esp
}
80106e9d:	90                   	nop
80106e9e:	c9                   	leave  
80106e9f:	c3                   	ret    

80106ea0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106ea0:	f3 0f 1e fb          	endbr32 
80106ea4:	55                   	push   %ebp
80106ea5:	89 e5                	mov    %esp,%ebp
80106ea7:	57                   	push   %edi
80106ea8:	56                   	push   %esi
80106ea9:	53                   	push   %ebx
80106eaa:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106ead:	8b 45 08             	mov    0x8(%ebp),%eax
80106eb0:	8b 40 30             	mov    0x30(%eax),%eax
80106eb3:	83 f8 40             	cmp    $0x40,%eax
80106eb6:	75 3b                	jne    80106ef3 <trap+0x53>
    if(myproc()->killed)
80106eb8:	e8 73 d6 ff ff       	call   80104530 <myproc>
80106ebd:	8b 40 24             	mov    0x24(%eax),%eax
80106ec0:	85 c0                	test   %eax,%eax
80106ec2:	74 05                	je     80106ec9 <trap+0x29>
      exit();
80106ec4:	e8 22 dd ff ff       	call   80104beb <exit>
    myproc()->tf = tf;
80106ec9:	e8 62 d6 ff ff       	call   80104530 <myproc>
80106ece:	8b 55 08             	mov    0x8(%ebp),%edx
80106ed1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ed4:	e8 a1 ec ff ff       	call   80105b7a <syscall>
    if(myproc()->killed)
80106ed9:	e8 52 d6 ff ff       	call   80104530 <myproc>
80106ede:	8b 40 24             	mov    0x24(%eax),%eax
80106ee1:	85 c0                	test   %eax,%eax
80106ee3:	0f 84 52 02 00 00    	je     8010713b <trap+0x29b>
      exit();
80106ee9:	e8 fd dc ff ff       	call   80104beb <exit>
    return;
80106eee:	e9 48 02 00 00       	jmp    8010713b <trap+0x29b>
  }
  char *addr;
  switch(tf->trapno){
80106ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ef6:	8b 40 30             	mov    0x30(%eax),%eax
80106ef9:	83 e8 0e             	sub    $0xe,%eax
80106efc:	83 f8 31             	cmp    $0x31,%eax
80106eff:	0f 87 fe 00 00 00    	ja     80107003 <trap+0x163>
80106f05:	8b 04 85 80 9c 10 80 	mov    -0x7fef6380(,%eax,4),%eax
80106f0c:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106f0f:	e8 81 d5 ff ff       	call   80104495 <cpuid>
80106f14:	85 c0                	test   %eax,%eax
80106f16:	75 3d                	jne    80106f55 <trap+0xb5>
      acquire(&tickslock);
80106f18:	83 ec 0c             	sub    $0xc,%esp
80106f1b:	68 00 87 11 80       	push   $0x80118700
80106f20:	e8 8a e5 ff ff       	call   801054af <acquire>
80106f25:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106f28:	a1 40 8f 11 80       	mov    0x80118f40,%eax
80106f2d:	83 c0 01             	add    $0x1,%eax
80106f30:	a3 40 8f 11 80       	mov    %eax,0x80118f40
      wakeup(&ticks);
80106f35:	83 ec 0c             	sub    $0xc,%esp
80106f38:	68 40 8f 11 80       	push   $0x80118f40
80106f3d:	e8 ed e1 ff ff       	call   8010512f <wakeup>
80106f42:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106f45:	83 ec 0c             	sub    $0xc,%esp
80106f48:	68 00 87 11 80       	push   $0x80118700
80106f4d:	e8 cf e5 ff ff       	call   80105521 <release>
80106f52:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106f55:	e8 cb c2 ff ff       	call   80103225 <lapiceoi>
    break;
80106f5a:	e9 5c 01 00 00       	jmp    801070bb <trap+0x21b>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106f5f:	e8 d0 ba ff ff       	call   80102a34 <ideintr>
    lapiceoi();
80106f64:	e8 bc c2 ff ff       	call   80103225 <lapiceoi>
    break;
80106f69:	e9 4d 01 00 00       	jmp    801070bb <trap+0x21b>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106f6e:	e8 e8 c0 ff ff       	call   8010305b <kbdintr>
    lapiceoi();
80106f73:	e8 ad c2 ff ff       	call   80103225 <lapiceoi>
    break;
80106f78:	e9 3e 01 00 00       	jmp    801070bb <trap+0x21b>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106f7d:	e8 9b 03 00 00       	call   8010731d <uartintr>
    lapiceoi();
80106f82:	e8 9e c2 ff ff       	call   80103225 <lapiceoi>
    break;
80106f87:	e9 2f 01 00 00       	jmp    801070bb <trap+0x21b>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f8f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106f92:	8b 45 08             	mov    0x8(%ebp),%eax
80106f95:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f99:	0f b7 d8             	movzwl %ax,%ebx
80106f9c:	e8 f4 d4 ff ff       	call   80104495 <cpuid>
80106fa1:	56                   	push   %esi
80106fa2:	53                   	push   %ebx
80106fa3:	50                   	push   %eax
80106fa4:	68 b0 9b 10 80       	push   $0x80109bb0
80106fa9:	e8 6a 94 ff ff       	call   80100418 <cprintf>
80106fae:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106fb1:	e8 6f c2 ff ff       	call   80103225 <lapiceoi>
    break;
80106fb6:	e9 00 01 00 00       	jmp    801070bb <trap+0x21b>
  case T_PGFLT:
    //Food for thought: How can one distinguish between a regular page fault and a decryption request?
    cprintf("p4Debug : Page fault !\n");
80106fbb:	83 ec 0c             	sub    $0xc,%esp
80106fbe:	68 d4 9b 10 80       	push   $0x80109bd4
80106fc3:	e8 50 94 ff ff       	call   80100418 <cprintf>
80106fc8:	83 c4 10             	add    $0x10,%esp
    addr = (char*)rcr2();
80106fcb:	e8 29 fd ff ff       	call   80106cf9 <rcr2>
80106fd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (mdecrypt(addr))
80106fd3:	83 ec 0c             	sub    $0xc,%esp
80106fd6:	ff 75 e4             	pushl  -0x1c(%ebp)
80106fd9:	e8 47 1c 00 00       	call   80108c25 <mdecrypt>
80106fde:	83 c4 10             	add    $0x10,%esp
80106fe1:	85 c0                	test   %eax,%eax
80106fe3:	0f 84 d1 00 00 00    	je     801070ba <trap+0x21a>
    {
        cprintf("p4Debug: Memory fault\n");
80106fe9:	83 ec 0c             	sub    $0xc,%esp
80106fec:	68 ec 9b 10 80       	push   $0x80109bec
80106ff1:	e8 22 94 ff ff       	call   80100418 <cprintf>
80106ff6:	83 c4 10             	add    $0x10,%esp
        exit();
80106ff9:	e8 ed db ff ff       	call   80104beb <exit>
    };
    break;
80106ffe:	e9 b7 00 00 00       	jmp    801070ba <trap+0x21a>
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80107003:	e8 28 d5 ff ff       	call   80104530 <myproc>
80107008:	85 c0                	test   %eax,%eax
8010700a:	74 11                	je     8010701d <trap+0x17d>
8010700c:	8b 45 08             	mov    0x8(%ebp),%eax
8010700f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107013:	0f b7 c0             	movzwl %ax,%eax
80107016:	83 e0 03             	and    $0x3,%eax
80107019:	85 c0                	test   %eax,%eax
8010701b:	75 39                	jne    80107056 <trap+0x1b6>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010701d:	e8 d7 fc ff ff       	call   80106cf9 <rcr2>
80107022:	89 c3                	mov    %eax,%ebx
80107024:	8b 45 08             	mov    0x8(%ebp),%eax
80107027:	8b 70 38             	mov    0x38(%eax),%esi
8010702a:	e8 66 d4 ff ff       	call   80104495 <cpuid>
8010702f:	8b 55 08             	mov    0x8(%ebp),%edx
80107032:	8b 52 30             	mov    0x30(%edx),%edx
80107035:	83 ec 0c             	sub    $0xc,%esp
80107038:	53                   	push   %ebx
80107039:	56                   	push   %esi
8010703a:	50                   	push   %eax
8010703b:	52                   	push   %edx
8010703c:	68 04 9c 10 80       	push   $0x80109c04
80107041:	e8 d2 93 ff ff       	call   80100418 <cprintf>
80107046:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107049:	83 ec 0c             	sub    $0xc,%esp
8010704c:	68 36 9c 10 80       	push   $0x80109c36
80107051:	e8 b2 95 ff ff       	call   80100608 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107056:	e8 9e fc ff ff       	call   80106cf9 <rcr2>
8010705b:	89 c6                	mov    %eax,%esi
8010705d:	8b 45 08             	mov    0x8(%ebp),%eax
80107060:	8b 40 38             	mov    0x38(%eax),%eax
80107063:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107066:	e8 2a d4 ff ff       	call   80104495 <cpuid>
8010706b:	89 c3                	mov    %eax,%ebx
8010706d:	8b 45 08             	mov    0x8(%ebp),%eax
80107070:	8b 48 34             	mov    0x34(%eax),%ecx
80107073:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80107076:	8b 45 08             	mov    0x8(%ebp),%eax
80107079:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010707c:	e8 af d4 ff ff       	call   80104530 <myproc>
80107081:	8d 50 6c             	lea    0x6c(%eax),%edx
80107084:	89 55 cc             	mov    %edx,-0x34(%ebp)
80107087:	e8 a4 d4 ff ff       	call   80104530 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010708c:	8b 40 10             	mov    0x10(%eax),%eax
8010708f:	56                   	push   %esi
80107090:	ff 75 d4             	pushl  -0x2c(%ebp)
80107093:	53                   	push   %ebx
80107094:	ff 75 d0             	pushl  -0x30(%ebp)
80107097:	57                   	push   %edi
80107098:	ff 75 cc             	pushl  -0x34(%ebp)
8010709b:	50                   	push   %eax
8010709c:	68 3c 9c 10 80       	push   $0x80109c3c
801070a1:	e8 72 93 ff ff       	call   80100418 <cprintf>
801070a6:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801070a9:	e8 82 d4 ff ff       	call   80104530 <myproc>
801070ae:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801070b5:	eb 04                	jmp    801070bb <trap+0x21b>
    break;
801070b7:	90                   	nop
801070b8:	eb 01                	jmp    801070bb <trap+0x21b>
    break;
801070ba:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801070bb:	e8 70 d4 ff ff       	call   80104530 <myproc>
801070c0:	85 c0                	test   %eax,%eax
801070c2:	74 23                	je     801070e7 <trap+0x247>
801070c4:	e8 67 d4 ff ff       	call   80104530 <myproc>
801070c9:	8b 40 24             	mov    0x24(%eax),%eax
801070cc:	85 c0                	test   %eax,%eax
801070ce:	74 17                	je     801070e7 <trap+0x247>
801070d0:	8b 45 08             	mov    0x8(%ebp),%eax
801070d3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801070d7:	0f b7 c0             	movzwl %ax,%eax
801070da:	83 e0 03             	and    $0x3,%eax
801070dd:	83 f8 03             	cmp    $0x3,%eax
801070e0:	75 05                	jne    801070e7 <trap+0x247>
    exit();
801070e2:	e8 04 db ff ff       	call   80104beb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801070e7:	e8 44 d4 ff ff       	call   80104530 <myproc>
801070ec:	85 c0                	test   %eax,%eax
801070ee:	74 1d                	je     8010710d <trap+0x26d>
801070f0:	e8 3b d4 ff ff       	call   80104530 <myproc>
801070f5:	8b 40 0c             	mov    0xc(%eax),%eax
801070f8:	83 f8 04             	cmp    $0x4,%eax
801070fb:	75 10                	jne    8010710d <trap+0x26d>
     tf->trapno == T_IRQ0+IRQ_TIMER)
801070fd:	8b 45 08             	mov    0x8(%ebp),%eax
80107100:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80107103:	83 f8 20             	cmp    $0x20,%eax
80107106:	75 05                	jne    8010710d <trap+0x26d>
    yield();
80107108:	e8 a8 de ff ff       	call   80104fb5 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010710d:	e8 1e d4 ff ff       	call   80104530 <myproc>
80107112:	85 c0                	test   %eax,%eax
80107114:	74 26                	je     8010713c <trap+0x29c>
80107116:	e8 15 d4 ff ff       	call   80104530 <myproc>
8010711b:	8b 40 24             	mov    0x24(%eax),%eax
8010711e:	85 c0                	test   %eax,%eax
80107120:	74 1a                	je     8010713c <trap+0x29c>
80107122:	8b 45 08             	mov    0x8(%ebp),%eax
80107125:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107129:	0f b7 c0             	movzwl %ax,%eax
8010712c:	83 e0 03             	and    $0x3,%eax
8010712f:	83 f8 03             	cmp    $0x3,%eax
80107132:	75 08                	jne    8010713c <trap+0x29c>
    exit();
80107134:	e8 b2 da ff ff       	call   80104beb <exit>
80107139:	eb 01                	jmp    8010713c <trap+0x29c>
    return;
8010713b:	90                   	nop
}
8010713c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010713f:	5b                   	pop    %ebx
80107140:	5e                   	pop    %esi
80107141:	5f                   	pop    %edi
80107142:	5d                   	pop    %ebp
80107143:	c3                   	ret    

80107144 <inb>:
{
80107144:	55                   	push   %ebp
80107145:	89 e5                	mov    %esp,%ebp
80107147:	83 ec 14             	sub    $0x14,%esp
8010714a:	8b 45 08             	mov    0x8(%ebp),%eax
8010714d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107151:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107155:	89 c2                	mov    %eax,%edx
80107157:	ec                   	in     (%dx),%al
80107158:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010715b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010715f:	c9                   	leave  
80107160:	c3                   	ret    

80107161 <outb>:
{
80107161:	55                   	push   %ebp
80107162:	89 e5                	mov    %esp,%ebp
80107164:	83 ec 08             	sub    $0x8,%esp
80107167:	8b 45 08             	mov    0x8(%ebp),%eax
8010716a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010716d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107171:	89 d0                	mov    %edx,%eax
80107173:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107176:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010717a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010717e:	ee                   	out    %al,(%dx)
}
8010717f:	90                   	nop
80107180:	c9                   	leave  
80107181:	c3                   	ret    

80107182 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107182:	f3 0f 1e fb          	endbr32 
80107186:	55                   	push   %ebp
80107187:	89 e5                	mov    %esp,%ebp
80107189:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010718c:	6a 00                	push   $0x0
8010718e:	68 fa 03 00 00       	push   $0x3fa
80107193:	e8 c9 ff ff ff       	call   80107161 <outb>
80107198:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010719b:	68 80 00 00 00       	push   $0x80
801071a0:	68 fb 03 00 00       	push   $0x3fb
801071a5:	e8 b7 ff ff ff       	call   80107161 <outb>
801071aa:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801071ad:	6a 0c                	push   $0xc
801071af:	68 f8 03 00 00       	push   $0x3f8
801071b4:	e8 a8 ff ff ff       	call   80107161 <outb>
801071b9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801071bc:	6a 00                	push   $0x0
801071be:	68 f9 03 00 00       	push   $0x3f9
801071c3:	e8 99 ff ff ff       	call   80107161 <outb>
801071c8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801071cb:	6a 03                	push   $0x3
801071cd:	68 fb 03 00 00       	push   $0x3fb
801071d2:	e8 8a ff ff ff       	call   80107161 <outb>
801071d7:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801071da:	6a 00                	push   $0x0
801071dc:	68 fc 03 00 00       	push   $0x3fc
801071e1:	e8 7b ff ff ff       	call   80107161 <outb>
801071e6:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801071e9:	6a 01                	push   $0x1
801071eb:	68 f9 03 00 00       	push   $0x3f9
801071f0:	e8 6c ff ff ff       	call   80107161 <outb>
801071f5:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801071f8:	68 fd 03 00 00       	push   $0x3fd
801071fd:	e8 42 ff ff ff       	call   80107144 <inb>
80107202:	83 c4 04             	add    $0x4,%esp
80107205:	3c ff                	cmp    $0xff,%al
80107207:	74 61                	je     8010726a <uartinit+0xe8>
    return;
  uart = 1;
80107209:	c7 05 44 d6 10 80 01 	movl   $0x1,0x8010d644
80107210:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107213:	68 fa 03 00 00       	push   $0x3fa
80107218:	e8 27 ff ff ff       	call   80107144 <inb>
8010721d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107220:	68 f8 03 00 00       	push   $0x3f8
80107225:	e8 1a ff ff ff       	call   80107144 <inb>
8010722a:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
8010722d:	83 ec 08             	sub    $0x8,%esp
80107230:	6a 00                	push   $0x0
80107232:	6a 04                	push   $0x4
80107234:	e8 ad ba ff ff       	call   80102ce6 <ioapicenable>
80107239:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010723c:	c7 45 f4 48 9d 10 80 	movl   $0x80109d48,-0xc(%ebp)
80107243:	eb 19                	jmp    8010725e <uartinit+0xdc>
    uartputc(*p);
80107245:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107248:	0f b6 00             	movzbl (%eax),%eax
8010724b:	0f be c0             	movsbl %al,%eax
8010724e:	83 ec 0c             	sub    $0xc,%esp
80107251:	50                   	push   %eax
80107252:	e8 16 00 00 00       	call   8010726d <uartputc>
80107257:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010725a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010725e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107261:	0f b6 00             	movzbl (%eax),%eax
80107264:	84 c0                	test   %al,%al
80107266:	75 dd                	jne    80107245 <uartinit+0xc3>
80107268:	eb 01                	jmp    8010726b <uartinit+0xe9>
    return;
8010726a:	90                   	nop
}
8010726b:	c9                   	leave  
8010726c:	c3                   	ret    

8010726d <uartputc>:

void
uartputc(int c)
{
8010726d:	f3 0f 1e fb          	endbr32 
80107271:	55                   	push   %ebp
80107272:	89 e5                	mov    %esp,%ebp
80107274:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107277:	a1 44 d6 10 80       	mov    0x8010d644,%eax
8010727c:	85 c0                	test   %eax,%eax
8010727e:	74 53                	je     801072d3 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107280:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107287:	eb 11                	jmp    8010729a <uartputc+0x2d>
    microdelay(10);
80107289:	83 ec 0c             	sub    $0xc,%esp
8010728c:	6a 0a                	push   $0xa
8010728e:	e8 b1 bf ff ff       	call   80103244 <microdelay>
80107293:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107296:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010729a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010729e:	7f 1a                	jg     801072ba <uartputc+0x4d>
801072a0:	83 ec 0c             	sub    $0xc,%esp
801072a3:	68 fd 03 00 00       	push   $0x3fd
801072a8:	e8 97 fe ff ff       	call   80107144 <inb>
801072ad:	83 c4 10             	add    $0x10,%esp
801072b0:	0f b6 c0             	movzbl %al,%eax
801072b3:	83 e0 20             	and    $0x20,%eax
801072b6:	85 c0                	test   %eax,%eax
801072b8:	74 cf                	je     80107289 <uartputc+0x1c>
  outb(COM1+0, c);
801072ba:	8b 45 08             	mov    0x8(%ebp),%eax
801072bd:	0f b6 c0             	movzbl %al,%eax
801072c0:	83 ec 08             	sub    $0x8,%esp
801072c3:	50                   	push   %eax
801072c4:	68 f8 03 00 00       	push   $0x3f8
801072c9:	e8 93 fe ff ff       	call   80107161 <outb>
801072ce:	83 c4 10             	add    $0x10,%esp
801072d1:	eb 01                	jmp    801072d4 <uartputc+0x67>
    return;
801072d3:	90                   	nop
}
801072d4:	c9                   	leave  
801072d5:	c3                   	ret    

801072d6 <uartgetc>:

static int
uartgetc(void)
{
801072d6:	f3 0f 1e fb          	endbr32 
801072da:	55                   	push   %ebp
801072db:	89 e5                	mov    %esp,%ebp
  if(!uart)
801072dd:	a1 44 d6 10 80       	mov    0x8010d644,%eax
801072e2:	85 c0                	test   %eax,%eax
801072e4:	75 07                	jne    801072ed <uartgetc+0x17>
    return -1;
801072e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072eb:	eb 2e                	jmp    8010731b <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801072ed:	68 fd 03 00 00       	push   $0x3fd
801072f2:	e8 4d fe ff ff       	call   80107144 <inb>
801072f7:	83 c4 04             	add    $0x4,%esp
801072fa:	0f b6 c0             	movzbl %al,%eax
801072fd:	83 e0 01             	and    $0x1,%eax
80107300:	85 c0                	test   %eax,%eax
80107302:	75 07                	jne    8010730b <uartgetc+0x35>
    return -1;
80107304:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107309:	eb 10                	jmp    8010731b <uartgetc+0x45>
  return inb(COM1+0);
8010730b:	68 f8 03 00 00       	push   $0x3f8
80107310:	e8 2f fe ff ff       	call   80107144 <inb>
80107315:	83 c4 04             	add    $0x4,%esp
80107318:	0f b6 c0             	movzbl %al,%eax
}
8010731b:	c9                   	leave  
8010731c:	c3                   	ret    

8010731d <uartintr>:

void
uartintr(void)
{
8010731d:	f3 0f 1e fb          	endbr32 
80107321:	55                   	push   %ebp
80107322:	89 e5                	mov    %esp,%ebp
80107324:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107327:	83 ec 0c             	sub    $0xc,%esp
8010732a:	68 d6 72 10 80       	push   $0x801072d6
8010732f:	e8 74 95 ff ff       	call   801008a8 <consoleintr>
80107334:	83 c4 10             	add    $0x10,%esp
}
80107337:	90                   	nop
80107338:	c9                   	leave  
80107339:	c3                   	ret    

8010733a <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $0
8010733c:	6a 00                	push   $0x0
  jmp alltraps
8010733e:	e9 69 f9 ff ff       	jmp    80106cac <alltraps>

80107343 <vector1>:
.globl vector1
vector1:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $1
80107345:	6a 01                	push   $0x1
  jmp alltraps
80107347:	e9 60 f9 ff ff       	jmp    80106cac <alltraps>

8010734c <vector2>:
.globl vector2
vector2:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $2
8010734e:	6a 02                	push   $0x2
  jmp alltraps
80107350:	e9 57 f9 ff ff       	jmp    80106cac <alltraps>

80107355 <vector3>:
.globl vector3
vector3:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $3
80107357:	6a 03                	push   $0x3
  jmp alltraps
80107359:	e9 4e f9 ff ff       	jmp    80106cac <alltraps>

8010735e <vector4>:
.globl vector4
vector4:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $4
80107360:	6a 04                	push   $0x4
  jmp alltraps
80107362:	e9 45 f9 ff ff       	jmp    80106cac <alltraps>

80107367 <vector5>:
.globl vector5
vector5:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $5
80107369:	6a 05                	push   $0x5
  jmp alltraps
8010736b:	e9 3c f9 ff ff       	jmp    80106cac <alltraps>

80107370 <vector6>:
.globl vector6
vector6:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $6
80107372:	6a 06                	push   $0x6
  jmp alltraps
80107374:	e9 33 f9 ff ff       	jmp    80106cac <alltraps>

80107379 <vector7>:
.globl vector7
vector7:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $7
8010737b:	6a 07                	push   $0x7
  jmp alltraps
8010737d:	e9 2a f9 ff ff       	jmp    80106cac <alltraps>

80107382 <vector8>:
.globl vector8
vector8:
  pushl $8
80107382:	6a 08                	push   $0x8
  jmp alltraps
80107384:	e9 23 f9 ff ff       	jmp    80106cac <alltraps>

80107389 <vector9>:
.globl vector9
vector9:
  pushl $0
80107389:	6a 00                	push   $0x0
  pushl $9
8010738b:	6a 09                	push   $0x9
  jmp alltraps
8010738d:	e9 1a f9 ff ff       	jmp    80106cac <alltraps>

80107392 <vector10>:
.globl vector10
vector10:
  pushl $10
80107392:	6a 0a                	push   $0xa
  jmp alltraps
80107394:	e9 13 f9 ff ff       	jmp    80106cac <alltraps>

80107399 <vector11>:
.globl vector11
vector11:
  pushl $11
80107399:	6a 0b                	push   $0xb
  jmp alltraps
8010739b:	e9 0c f9 ff ff       	jmp    80106cac <alltraps>

801073a0 <vector12>:
.globl vector12
vector12:
  pushl $12
801073a0:	6a 0c                	push   $0xc
  jmp alltraps
801073a2:	e9 05 f9 ff ff       	jmp    80106cac <alltraps>

801073a7 <vector13>:
.globl vector13
vector13:
  pushl $13
801073a7:	6a 0d                	push   $0xd
  jmp alltraps
801073a9:	e9 fe f8 ff ff       	jmp    80106cac <alltraps>

801073ae <vector14>:
.globl vector14
vector14:
  pushl $14
801073ae:	6a 0e                	push   $0xe
  jmp alltraps
801073b0:	e9 f7 f8 ff ff       	jmp    80106cac <alltraps>

801073b5 <vector15>:
.globl vector15
vector15:
  pushl $0
801073b5:	6a 00                	push   $0x0
  pushl $15
801073b7:	6a 0f                	push   $0xf
  jmp alltraps
801073b9:	e9 ee f8 ff ff       	jmp    80106cac <alltraps>

801073be <vector16>:
.globl vector16
vector16:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $16
801073c0:	6a 10                	push   $0x10
  jmp alltraps
801073c2:	e9 e5 f8 ff ff       	jmp    80106cac <alltraps>

801073c7 <vector17>:
.globl vector17
vector17:
  pushl $17
801073c7:	6a 11                	push   $0x11
  jmp alltraps
801073c9:	e9 de f8 ff ff       	jmp    80106cac <alltraps>

801073ce <vector18>:
.globl vector18
vector18:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $18
801073d0:	6a 12                	push   $0x12
  jmp alltraps
801073d2:	e9 d5 f8 ff ff       	jmp    80106cac <alltraps>

801073d7 <vector19>:
.globl vector19
vector19:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $19
801073d9:	6a 13                	push   $0x13
  jmp alltraps
801073db:	e9 cc f8 ff ff       	jmp    80106cac <alltraps>

801073e0 <vector20>:
.globl vector20
vector20:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $20
801073e2:	6a 14                	push   $0x14
  jmp alltraps
801073e4:	e9 c3 f8 ff ff       	jmp    80106cac <alltraps>

801073e9 <vector21>:
.globl vector21
vector21:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $21
801073eb:	6a 15                	push   $0x15
  jmp alltraps
801073ed:	e9 ba f8 ff ff       	jmp    80106cac <alltraps>

801073f2 <vector22>:
.globl vector22
vector22:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $22
801073f4:	6a 16                	push   $0x16
  jmp alltraps
801073f6:	e9 b1 f8 ff ff       	jmp    80106cac <alltraps>

801073fb <vector23>:
.globl vector23
vector23:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $23
801073fd:	6a 17                	push   $0x17
  jmp alltraps
801073ff:	e9 a8 f8 ff ff       	jmp    80106cac <alltraps>

80107404 <vector24>:
.globl vector24
vector24:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $24
80107406:	6a 18                	push   $0x18
  jmp alltraps
80107408:	e9 9f f8 ff ff       	jmp    80106cac <alltraps>

8010740d <vector25>:
.globl vector25
vector25:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $25
8010740f:	6a 19                	push   $0x19
  jmp alltraps
80107411:	e9 96 f8 ff ff       	jmp    80106cac <alltraps>

80107416 <vector26>:
.globl vector26
vector26:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $26
80107418:	6a 1a                	push   $0x1a
  jmp alltraps
8010741a:	e9 8d f8 ff ff       	jmp    80106cac <alltraps>

8010741f <vector27>:
.globl vector27
vector27:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $27
80107421:	6a 1b                	push   $0x1b
  jmp alltraps
80107423:	e9 84 f8 ff ff       	jmp    80106cac <alltraps>

80107428 <vector28>:
.globl vector28
vector28:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $28
8010742a:	6a 1c                	push   $0x1c
  jmp alltraps
8010742c:	e9 7b f8 ff ff       	jmp    80106cac <alltraps>

80107431 <vector29>:
.globl vector29
vector29:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $29
80107433:	6a 1d                	push   $0x1d
  jmp alltraps
80107435:	e9 72 f8 ff ff       	jmp    80106cac <alltraps>

8010743a <vector30>:
.globl vector30
vector30:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $30
8010743c:	6a 1e                	push   $0x1e
  jmp alltraps
8010743e:	e9 69 f8 ff ff       	jmp    80106cac <alltraps>

80107443 <vector31>:
.globl vector31
vector31:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $31
80107445:	6a 1f                	push   $0x1f
  jmp alltraps
80107447:	e9 60 f8 ff ff       	jmp    80106cac <alltraps>

8010744c <vector32>:
.globl vector32
vector32:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $32
8010744e:	6a 20                	push   $0x20
  jmp alltraps
80107450:	e9 57 f8 ff ff       	jmp    80106cac <alltraps>

80107455 <vector33>:
.globl vector33
vector33:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $33
80107457:	6a 21                	push   $0x21
  jmp alltraps
80107459:	e9 4e f8 ff ff       	jmp    80106cac <alltraps>

8010745e <vector34>:
.globl vector34
vector34:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $34
80107460:	6a 22                	push   $0x22
  jmp alltraps
80107462:	e9 45 f8 ff ff       	jmp    80106cac <alltraps>

80107467 <vector35>:
.globl vector35
vector35:
  pushl $0
80107467:	6a 00                	push   $0x0
  pushl $35
80107469:	6a 23                	push   $0x23
  jmp alltraps
8010746b:	e9 3c f8 ff ff       	jmp    80106cac <alltraps>

80107470 <vector36>:
.globl vector36
vector36:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $36
80107472:	6a 24                	push   $0x24
  jmp alltraps
80107474:	e9 33 f8 ff ff       	jmp    80106cac <alltraps>

80107479 <vector37>:
.globl vector37
vector37:
  pushl $0
80107479:	6a 00                	push   $0x0
  pushl $37
8010747b:	6a 25                	push   $0x25
  jmp alltraps
8010747d:	e9 2a f8 ff ff       	jmp    80106cac <alltraps>

80107482 <vector38>:
.globl vector38
vector38:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $38
80107484:	6a 26                	push   $0x26
  jmp alltraps
80107486:	e9 21 f8 ff ff       	jmp    80106cac <alltraps>

8010748b <vector39>:
.globl vector39
vector39:
  pushl $0
8010748b:	6a 00                	push   $0x0
  pushl $39
8010748d:	6a 27                	push   $0x27
  jmp alltraps
8010748f:	e9 18 f8 ff ff       	jmp    80106cac <alltraps>

80107494 <vector40>:
.globl vector40
vector40:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $40
80107496:	6a 28                	push   $0x28
  jmp alltraps
80107498:	e9 0f f8 ff ff       	jmp    80106cac <alltraps>

8010749d <vector41>:
.globl vector41
vector41:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $41
8010749f:	6a 29                	push   $0x29
  jmp alltraps
801074a1:	e9 06 f8 ff ff       	jmp    80106cac <alltraps>

801074a6 <vector42>:
.globl vector42
vector42:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $42
801074a8:	6a 2a                	push   $0x2a
  jmp alltraps
801074aa:	e9 fd f7 ff ff       	jmp    80106cac <alltraps>

801074af <vector43>:
.globl vector43
vector43:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $43
801074b1:	6a 2b                	push   $0x2b
  jmp alltraps
801074b3:	e9 f4 f7 ff ff       	jmp    80106cac <alltraps>

801074b8 <vector44>:
.globl vector44
vector44:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $44
801074ba:	6a 2c                	push   $0x2c
  jmp alltraps
801074bc:	e9 eb f7 ff ff       	jmp    80106cac <alltraps>

801074c1 <vector45>:
.globl vector45
vector45:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $45
801074c3:	6a 2d                	push   $0x2d
  jmp alltraps
801074c5:	e9 e2 f7 ff ff       	jmp    80106cac <alltraps>

801074ca <vector46>:
.globl vector46
vector46:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $46
801074cc:	6a 2e                	push   $0x2e
  jmp alltraps
801074ce:	e9 d9 f7 ff ff       	jmp    80106cac <alltraps>

801074d3 <vector47>:
.globl vector47
vector47:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $47
801074d5:	6a 2f                	push   $0x2f
  jmp alltraps
801074d7:	e9 d0 f7 ff ff       	jmp    80106cac <alltraps>

801074dc <vector48>:
.globl vector48
vector48:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $48
801074de:	6a 30                	push   $0x30
  jmp alltraps
801074e0:	e9 c7 f7 ff ff       	jmp    80106cac <alltraps>

801074e5 <vector49>:
.globl vector49
vector49:
  pushl $0
801074e5:	6a 00                	push   $0x0
  pushl $49
801074e7:	6a 31                	push   $0x31
  jmp alltraps
801074e9:	e9 be f7 ff ff       	jmp    80106cac <alltraps>

801074ee <vector50>:
.globl vector50
vector50:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $50
801074f0:	6a 32                	push   $0x32
  jmp alltraps
801074f2:	e9 b5 f7 ff ff       	jmp    80106cac <alltraps>

801074f7 <vector51>:
.globl vector51
vector51:
  pushl $0
801074f7:	6a 00                	push   $0x0
  pushl $51
801074f9:	6a 33                	push   $0x33
  jmp alltraps
801074fb:	e9 ac f7 ff ff       	jmp    80106cac <alltraps>

80107500 <vector52>:
.globl vector52
vector52:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $52
80107502:	6a 34                	push   $0x34
  jmp alltraps
80107504:	e9 a3 f7 ff ff       	jmp    80106cac <alltraps>

80107509 <vector53>:
.globl vector53
vector53:
  pushl $0
80107509:	6a 00                	push   $0x0
  pushl $53
8010750b:	6a 35                	push   $0x35
  jmp alltraps
8010750d:	e9 9a f7 ff ff       	jmp    80106cac <alltraps>

80107512 <vector54>:
.globl vector54
vector54:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $54
80107514:	6a 36                	push   $0x36
  jmp alltraps
80107516:	e9 91 f7 ff ff       	jmp    80106cac <alltraps>

8010751b <vector55>:
.globl vector55
vector55:
  pushl $0
8010751b:	6a 00                	push   $0x0
  pushl $55
8010751d:	6a 37                	push   $0x37
  jmp alltraps
8010751f:	e9 88 f7 ff ff       	jmp    80106cac <alltraps>

80107524 <vector56>:
.globl vector56
vector56:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $56
80107526:	6a 38                	push   $0x38
  jmp alltraps
80107528:	e9 7f f7 ff ff       	jmp    80106cac <alltraps>

8010752d <vector57>:
.globl vector57
vector57:
  pushl $0
8010752d:	6a 00                	push   $0x0
  pushl $57
8010752f:	6a 39                	push   $0x39
  jmp alltraps
80107531:	e9 76 f7 ff ff       	jmp    80106cac <alltraps>

80107536 <vector58>:
.globl vector58
vector58:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $58
80107538:	6a 3a                	push   $0x3a
  jmp alltraps
8010753a:	e9 6d f7 ff ff       	jmp    80106cac <alltraps>

8010753f <vector59>:
.globl vector59
vector59:
  pushl $0
8010753f:	6a 00                	push   $0x0
  pushl $59
80107541:	6a 3b                	push   $0x3b
  jmp alltraps
80107543:	e9 64 f7 ff ff       	jmp    80106cac <alltraps>

80107548 <vector60>:
.globl vector60
vector60:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $60
8010754a:	6a 3c                	push   $0x3c
  jmp alltraps
8010754c:	e9 5b f7 ff ff       	jmp    80106cac <alltraps>

80107551 <vector61>:
.globl vector61
vector61:
  pushl $0
80107551:	6a 00                	push   $0x0
  pushl $61
80107553:	6a 3d                	push   $0x3d
  jmp alltraps
80107555:	e9 52 f7 ff ff       	jmp    80106cac <alltraps>

8010755a <vector62>:
.globl vector62
vector62:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $62
8010755c:	6a 3e                	push   $0x3e
  jmp alltraps
8010755e:	e9 49 f7 ff ff       	jmp    80106cac <alltraps>

80107563 <vector63>:
.globl vector63
vector63:
  pushl $0
80107563:	6a 00                	push   $0x0
  pushl $63
80107565:	6a 3f                	push   $0x3f
  jmp alltraps
80107567:	e9 40 f7 ff ff       	jmp    80106cac <alltraps>

8010756c <vector64>:
.globl vector64
vector64:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $64
8010756e:	6a 40                	push   $0x40
  jmp alltraps
80107570:	e9 37 f7 ff ff       	jmp    80106cac <alltraps>

80107575 <vector65>:
.globl vector65
vector65:
  pushl $0
80107575:	6a 00                	push   $0x0
  pushl $65
80107577:	6a 41                	push   $0x41
  jmp alltraps
80107579:	e9 2e f7 ff ff       	jmp    80106cac <alltraps>

8010757e <vector66>:
.globl vector66
vector66:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $66
80107580:	6a 42                	push   $0x42
  jmp alltraps
80107582:	e9 25 f7 ff ff       	jmp    80106cac <alltraps>

80107587 <vector67>:
.globl vector67
vector67:
  pushl $0
80107587:	6a 00                	push   $0x0
  pushl $67
80107589:	6a 43                	push   $0x43
  jmp alltraps
8010758b:	e9 1c f7 ff ff       	jmp    80106cac <alltraps>

80107590 <vector68>:
.globl vector68
vector68:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $68
80107592:	6a 44                	push   $0x44
  jmp alltraps
80107594:	e9 13 f7 ff ff       	jmp    80106cac <alltraps>

80107599 <vector69>:
.globl vector69
vector69:
  pushl $0
80107599:	6a 00                	push   $0x0
  pushl $69
8010759b:	6a 45                	push   $0x45
  jmp alltraps
8010759d:	e9 0a f7 ff ff       	jmp    80106cac <alltraps>

801075a2 <vector70>:
.globl vector70
vector70:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $70
801075a4:	6a 46                	push   $0x46
  jmp alltraps
801075a6:	e9 01 f7 ff ff       	jmp    80106cac <alltraps>

801075ab <vector71>:
.globl vector71
vector71:
  pushl $0
801075ab:	6a 00                	push   $0x0
  pushl $71
801075ad:	6a 47                	push   $0x47
  jmp alltraps
801075af:	e9 f8 f6 ff ff       	jmp    80106cac <alltraps>

801075b4 <vector72>:
.globl vector72
vector72:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $72
801075b6:	6a 48                	push   $0x48
  jmp alltraps
801075b8:	e9 ef f6 ff ff       	jmp    80106cac <alltraps>

801075bd <vector73>:
.globl vector73
vector73:
  pushl $0
801075bd:	6a 00                	push   $0x0
  pushl $73
801075bf:	6a 49                	push   $0x49
  jmp alltraps
801075c1:	e9 e6 f6 ff ff       	jmp    80106cac <alltraps>

801075c6 <vector74>:
.globl vector74
vector74:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $74
801075c8:	6a 4a                	push   $0x4a
  jmp alltraps
801075ca:	e9 dd f6 ff ff       	jmp    80106cac <alltraps>

801075cf <vector75>:
.globl vector75
vector75:
  pushl $0
801075cf:	6a 00                	push   $0x0
  pushl $75
801075d1:	6a 4b                	push   $0x4b
  jmp alltraps
801075d3:	e9 d4 f6 ff ff       	jmp    80106cac <alltraps>

801075d8 <vector76>:
.globl vector76
vector76:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $76
801075da:	6a 4c                	push   $0x4c
  jmp alltraps
801075dc:	e9 cb f6 ff ff       	jmp    80106cac <alltraps>

801075e1 <vector77>:
.globl vector77
vector77:
  pushl $0
801075e1:	6a 00                	push   $0x0
  pushl $77
801075e3:	6a 4d                	push   $0x4d
  jmp alltraps
801075e5:	e9 c2 f6 ff ff       	jmp    80106cac <alltraps>

801075ea <vector78>:
.globl vector78
vector78:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $78
801075ec:	6a 4e                	push   $0x4e
  jmp alltraps
801075ee:	e9 b9 f6 ff ff       	jmp    80106cac <alltraps>

801075f3 <vector79>:
.globl vector79
vector79:
  pushl $0
801075f3:	6a 00                	push   $0x0
  pushl $79
801075f5:	6a 4f                	push   $0x4f
  jmp alltraps
801075f7:	e9 b0 f6 ff ff       	jmp    80106cac <alltraps>

801075fc <vector80>:
.globl vector80
vector80:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $80
801075fe:	6a 50                	push   $0x50
  jmp alltraps
80107600:	e9 a7 f6 ff ff       	jmp    80106cac <alltraps>

80107605 <vector81>:
.globl vector81
vector81:
  pushl $0
80107605:	6a 00                	push   $0x0
  pushl $81
80107607:	6a 51                	push   $0x51
  jmp alltraps
80107609:	e9 9e f6 ff ff       	jmp    80106cac <alltraps>

8010760e <vector82>:
.globl vector82
vector82:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $82
80107610:	6a 52                	push   $0x52
  jmp alltraps
80107612:	e9 95 f6 ff ff       	jmp    80106cac <alltraps>

80107617 <vector83>:
.globl vector83
vector83:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $83
80107619:	6a 53                	push   $0x53
  jmp alltraps
8010761b:	e9 8c f6 ff ff       	jmp    80106cac <alltraps>

80107620 <vector84>:
.globl vector84
vector84:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $84
80107622:	6a 54                	push   $0x54
  jmp alltraps
80107624:	e9 83 f6 ff ff       	jmp    80106cac <alltraps>

80107629 <vector85>:
.globl vector85
vector85:
  pushl $0
80107629:	6a 00                	push   $0x0
  pushl $85
8010762b:	6a 55                	push   $0x55
  jmp alltraps
8010762d:	e9 7a f6 ff ff       	jmp    80106cac <alltraps>

80107632 <vector86>:
.globl vector86
vector86:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $86
80107634:	6a 56                	push   $0x56
  jmp alltraps
80107636:	e9 71 f6 ff ff       	jmp    80106cac <alltraps>

8010763b <vector87>:
.globl vector87
vector87:
  pushl $0
8010763b:	6a 00                	push   $0x0
  pushl $87
8010763d:	6a 57                	push   $0x57
  jmp alltraps
8010763f:	e9 68 f6 ff ff       	jmp    80106cac <alltraps>

80107644 <vector88>:
.globl vector88
vector88:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $88
80107646:	6a 58                	push   $0x58
  jmp alltraps
80107648:	e9 5f f6 ff ff       	jmp    80106cac <alltraps>

8010764d <vector89>:
.globl vector89
vector89:
  pushl $0
8010764d:	6a 00                	push   $0x0
  pushl $89
8010764f:	6a 59                	push   $0x59
  jmp alltraps
80107651:	e9 56 f6 ff ff       	jmp    80106cac <alltraps>

80107656 <vector90>:
.globl vector90
vector90:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $90
80107658:	6a 5a                	push   $0x5a
  jmp alltraps
8010765a:	e9 4d f6 ff ff       	jmp    80106cac <alltraps>

8010765f <vector91>:
.globl vector91
vector91:
  pushl $0
8010765f:	6a 00                	push   $0x0
  pushl $91
80107661:	6a 5b                	push   $0x5b
  jmp alltraps
80107663:	e9 44 f6 ff ff       	jmp    80106cac <alltraps>

80107668 <vector92>:
.globl vector92
vector92:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $92
8010766a:	6a 5c                	push   $0x5c
  jmp alltraps
8010766c:	e9 3b f6 ff ff       	jmp    80106cac <alltraps>

80107671 <vector93>:
.globl vector93
vector93:
  pushl $0
80107671:	6a 00                	push   $0x0
  pushl $93
80107673:	6a 5d                	push   $0x5d
  jmp alltraps
80107675:	e9 32 f6 ff ff       	jmp    80106cac <alltraps>

8010767a <vector94>:
.globl vector94
vector94:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $94
8010767c:	6a 5e                	push   $0x5e
  jmp alltraps
8010767e:	e9 29 f6 ff ff       	jmp    80106cac <alltraps>

80107683 <vector95>:
.globl vector95
vector95:
  pushl $0
80107683:	6a 00                	push   $0x0
  pushl $95
80107685:	6a 5f                	push   $0x5f
  jmp alltraps
80107687:	e9 20 f6 ff ff       	jmp    80106cac <alltraps>

8010768c <vector96>:
.globl vector96
vector96:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $96
8010768e:	6a 60                	push   $0x60
  jmp alltraps
80107690:	e9 17 f6 ff ff       	jmp    80106cac <alltraps>

80107695 <vector97>:
.globl vector97
vector97:
  pushl $0
80107695:	6a 00                	push   $0x0
  pushl $97
80107697:	6a 61                	push   $0x61
  jmp alltraps
80107699:	e9 0e f6 ff ff       	jmp    80106cac <alltraps>

8010769e <vector98>:
.globl vector98
vector98:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $98
801076a0:	6a 62                	push   $0x62
  jmp alltraps
801076a2:	e9 05 f6 ff ff       	jmp    80106cac <alltraps>

801076a7 <vector99>:
.globl vector99
vector99:
  pushl $0
801076a7:	6a 00                	push   $0x0
  pushl $99
801076a9:	6a 63                	push   $0x63
  jmp alltraps
801076ab:	e9 fc f5 ff ff       	jmp    80106cac <alltraps>

801076b0 <vector100>:
.globl vector100
vector100:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $100
801076b2:	6a 64                	push   $0x64
  jmp alltraps
801076b4:	e9 f3 f5 ff ff       	jmp    80106cac <alltraps>

801076b9 <vector101>:
.globl vector101
vector101:
  pushl $0
801076b9:	6a 00                	push   $0x0
  pushl $101
801076bb:	6a 65                	push   $0x65
  jmp alltraps
801076bd:	e9 ea f5 ff ff       	jmp    80106cac <alltraps>

801076c2 <vector102>:
.globl vector102
vector102:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $102
801076c4:	6a 66                	push   $0x66
  jmp alltraps
801076c6:	e9 e1 f5 ff ff       	jmp    80106cac <alltraps>

801076cb <vector103>:
.globl vector103
vector103:
  pushl $0
801076cb:	6a 00                	push   $0x0
  pushl $103
801076cd:	6a 67                	push   $0x67
  jmp alltraps
801076cf:	e9 d8 f5 ff ff       	jmp    80106cac <alltraps>

801076d4 <vector104>:
.globl vector104
vector104:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $104
801076d6:	6a 68                	push   $0x68
  jmp alltraps
801076d8:	e9 cf f5 ff ff       	jmp    80106cac <alltraps>

801076dd <vector105>:
.globl vector105
vector105:
  pushl $0
801076dd:	6a 00                	push   $0x0
  pushl $105
801076df:	6a 69                	push   $0x69
  jmp alltraps
801076e1:	e9 c6 f5 ff ff       	jmp    80106cac <alltraps>

801076e6 <vector106>:
.globl vector106
vector106:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $106
801076e8:	6a 6a                	push   $0x6a
  jmp alltraps
801076ea:	e9 bd f5 ff ff       	jmp    80106cac <alltraps>

801076ef <vector107>:
.globl vector107
vector107:
  pushl $0
801076ef:	6a 00                	push   $0x0
  pushl $107
801076f1:	6a 6b                	push   $0x6b
  jmp alltraps
801076f3:	e9 b4 f5 ff ff       	jmp    80106cac <alltraps>

801076f8 <vector108>:
.globl vector108
vector108:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $108
801076fa:	6a 6c                	push   $0x6c
  jmp alltraps
801076fc:	e9 ab f5 ff ff       	jmp    80106cac <alltraps>

80107701 <vector109>:
.globl vector109
vector109:
  pushl $0
80107701:	6a 00                	push   $0x0
  pushl $109
80107703:	6a 6d                	push   $0x6d
  jmp alltraps
80107705:	e9 a2 f5 ff ff       	jmp    80106cac <alltraps>

8010770a <vector110>:
.globl vector110
vector110:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $110
8010770c:	6a 6e                	push   $0x6e
  jmp alltraps
8010770e:	e9 99 f5 ff ff       	jmp    80106cac <alltraps>

80107713 <vector111>:
.globl vector111
vector111:
  pushl $0
80107713:	6a 00                	push   $0x0
  pushl $111
80107715:	6a 6f                	push   $0x6f
  jmp alltraps
80107717:	e9 90 f5 ff ff       	jmp    80106cac <alltraps>

8010771c <vector112>:
.globl vector112
vector112:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $112
8010771e:	6a 70                	push   $0x70
  jmp alltraps
80107720:	e9 87 f5 ff ff       	jmp    80106cac <alltraps>

80107725 <vector113>:
.globl vector113
vector113:
  pushl $0
80107725:	6a 00                	push   $0x0
  pushl $113
80107727:	6a 71                	push   $0x71
  jmp alltraps
80107729:	e9 7e f5 ff ff       	jmp    80106cac <alltraps>

8010772e <vector114>:
.globl vector114
vector114:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $114
80107730:	6a 72                	push   $0x72
  jmp alltraps
80107732:	e9 75 f5 ff ff       	jmp    80106cac <alltraps>

80107737 <vector115>:
.globl vector115
vector115:
  pushl $0
80107737:	6a 00                	push   $0x0
  pushl $115
80107739:	6a 73                	push   $0x73
  jmp alltraps
8010773b:	e9 6c f5 ff ff       	jmp    80106cac <alltraps>

80107740 <vector116>:
.globl vector116
vector116:
  pushl $0
80107740:	6a 00                	push   $0x0
  pushl $116
80107742:	6a 74                	push   $0x74
  jmp alltraps
80107744:	e9 63 f5 ff ff       	jmp    80106cac <alltraps>

80107749 <vector117>:
.globl vector117
vector117:
  pushl $0
80107749:	6a 00                	push   $0x0
  pushl $117
8010774b:	6a 75                	push   $0x75
  jmp alltraps
8010774d:	e9 5a f5 ff ff       	jmp    80106cac <alltraps>

80107752 <vector118>:
.globl vector118
vector118:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $118
80107754:	6a 76                	push   $0x76
  jmp alltraps
80107756:	e9 51 f5 ff ff       	jmp    80106cac <alltraps>

8010775b <vector119>:
.globl vector119
vector119:
  pushl $0
8010775b:	6a 00                	push   $0x0
  pushl $119
8010775d:	6a 77                	push   $0x77
  jmp alltraps
8010775f:	e9 48 f5 ff ff       	jmp    80106cac <alltraps>

80107764 <vector120>:
.globl vector120
vector120:
  pushl $0
80107764:	6a 00                	push   $0x0
  pushl $120
80107766:	6a 78                	push   $0x78
  jmp alltraps
80107768:	e9 3f f5 ff ff       	jmp    80106cac <alltraps>

8010776d <vector121>:
.globl vector121
vector121:
  pushl $0
8010776d:	6a 00                	push   $0x0
  pushl $121
8010776f:	6a 79                	push   $0x79
  jmp alltraps
80107771:	e9 36 f5 ff ff       	jmp    80106cac <alltraps>

80107776 <vector122>:
.globl vector122
vector122:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $122
80107778:	6a 7a                	push   $0x7a
  jmp alltraps
8010777a:	e9 2d f5 ff ff       	jmp    80106cac <alltraps>

8010777f <vector123>:
.globl vector123
vector123:
  pushl $0
8010777f:	6a 00                	push   $0x0
  pushl $123
80107781:	6a 7b                	push   $0x7b
  jmp alltraps
80107783:	e9 24 f5 ff ff       	jmp    80106cac <alltraps>

80107788 <vector124>:
.globl vector124
vector124:
  pushl $0
80107788:	6a 00                	push   $0x0
  pushl $124
8010778a:	6a 7c                	push   $0x7c
  jmp alltraps
8010778c:	e9 1b f5 ff ff       	jmp    80106cac <alltraps>

80107791 <vector125>:
.globl vector125
vector125:
  pushl $0
80107791:	6a 00                	push   $0x0
  pushl $125
80107793:	6a 7d                	push   $0x7d
  jmp alltraps
80107795:	e9 12 f5 ff ff       	jmp    80106cac <alltraps>

8010779a <vector126>:
.globl vector126
vector126:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $126
8010779c:	6a 7e                	push   $0x7e
  jmp alltraps
8010779e:	e9 09 f5 ff ff       	jmp    80106cac <alltraps>

801077a3 <vector127>:
.globl vector127
vector127:
  pushl $0
801077a3:	6a 00                	push   $0x0
  pushl $127
801077a5:	6a 7f                	push   $0x7f
  jmp alltraps
801077a7:	e9 00 f5 ff ff       	jmp    80106cac <alltraps>

801077ac <vector128>:
.globl vector128
vector128:
  pushl $0
801077ac:	6a 00                	push   $0x0
  pushl $128
801077ae:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801077b3:	e9 f4 f4 ff ff       	jmp    80106cac <alltraps>

801077b8 <vector129>:
.globl vector129
vector129:
  pushl $0
801077b8:	6a 00                	push   $0x0
  pushl $129
801077ba:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801077bf:	e9 e8 f4 ff ff       	jmp    80106cac <alltraps>

801077c4 <vector130>:
.globl vector130
vector130:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $130
801077c6:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801077cb:	e9 dc f4 ff ff       	jmp    80106cac <alltraps>

801077d0 <vector131>:
.globl vector131
vector131:
  pushl $0
801077d0:	6a 00                	push   $0x0
  pushl $131
801077d2:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801077d7:	e9 d0 f4 ff ff       	jmp    80106cac <alltraps>

801077dc <vector132>:
.globl vector132
vector132:
  pushl $0
801077dc:	6a 00                	push   $0x0
  pushl $132
801077de:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801077e3:	e9 c4 f4 ff ff       	jmp    80106cac <alltraps>

801077e8 <vector133>:
.globl vector133
vector133:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $133
801077ea:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801077ef:	e9 b8 f4 ff ff       	jmp    80106cac <alltraps>

801077f4 <vector134>:
.globl vector134
vector134:
  pushl $0
801077f4:	6a 00                	push   $0x0
  pushl $134
801077f6:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801077fb:	e9 ac f4 ff ff       	jmp    80106cac <alltraps>

80107800 <vector135>:
.globl vector135
vector135:
  pushl $0
80107800:	6a 00                	push   $0x0
  pushl $135
80107802:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107807:	e9 a0 f4 ff ff       	jmp    80106cac <alltraps>

8010780c <vector136>:
.globl vector136
vector136:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $136
8010780e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107813:	e9 94 f4 ff ff       	jmp    80106cac <alltraps>

80107818 <vector137>:
.globl vector137
vector137:
  pushl $0
80107818:	6a 00                	push   $0x0
  pushl $137
8010781a:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010781f:	e9 88 f4 ff ff       	jmp    80106cac <alltraps>

80107824 <vector138>:
.globl vector138
vector138:
  pushl $0
80107824:	6a 00                	push   $0x0
  pushl $138
80107826:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010782b:	e9 7c f4 ff ff       	jmp    80106cac <alltraps>

80107830 <vector139>:
.globl vector139
vector139:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $139
80107832:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107837:	e9 70 f4 ff ff       	jmp    80106cac <alltraps>

8010783c <vector140>:
.globl vector140
vector140:
  pushl $0
8010783c:	6a 00                	push   $0x0
  pushl $140
8010783e:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107843:	e9 64 f4 ff ff       	jmp    80106cac <alltraps>

80107848 <vector141>:
.globl vector141
vector141:
  pushl $0
80107848:	6a 00                	push   $0x0
  pushl $141
8010784a:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010784f:	e9 58 f4 ff ff       	jmp    80106cac <alltraps>

80107854 <vector142>:
.globl vector142
vector142:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $142
80107856:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010785b:	e9 4c f4 ff ff       	jmp    80106cac <alltraps>

80107860 <vector143>:
.globl vector143
vector143:
  pushl $0
80107860:	6a 00                	push   $0x0
  pushl $143
80107862:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107867:	e9 40 f4 ff ff       	jmp    80106cac <alltraps>

8010786c <vector144>:
.globl vector144
vector144:
  pushl $0
8010786c:	6a 00                	push   $0x0
  pushl $144
8010786e:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107873:	e9 34 f4 ff ff       	jmp    80106cac <alltraps>

80107878 <vector145>:
.globl vector145
vector145:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $145
8010787a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010787f:	e9 28 f4 ff ff       	jmp    80106cac <alltraps>

80107884 <vector146>:
.globl vector146
vector146:
  pushl $0
80107884:	6a 00                	push   $0x0
  pushl $146
80107886:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010788b:	e9 1c f4 ff ff       	jmp    80106cac <alltraps>

80107890 <vector147>:
.globl vector147
vector147:
  pushl $0
80107890:	6a 00                	push   $0x0
  pushl $147
80107892:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107897:	e9 10 f4 ff ff       	jmp    80106cac <alltraps>

8010789c <vector148>:
.globl vector148
vector148:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $148
8010789e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801078a3:	e9 04 f4 ff ff       	jmp    80106cac <alltraps>

801078a8 <vector149>:
.globl vector149
vector149:
  pushl $0
801078a8:	6a 00                	push   $0x0
  pushl $149
801078aa:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801078af:	e9 f8 f3 ff ff       	jmp    80106cac <alltraps>

801078b4 <vector150>:
.globl vector150
vector150:
  pushl $0
801078b4:	6a 00                	push   $0x0
  pushl $150
801078b6:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801078bb:	e9 ec f3 ff ff       	jmp    80106cac <alltraps>

801078c0 <vector151>:
.globl vector151
vector151:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $151
801078c2:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801078c7:	e9 e0 f3 ff ff       	jmp    80106cac <alltraps>

801078cc <vector152>:
.globl vector152
vector152:
  pushl $0
801078cc:	6a 00                	push   $0x0
  pushl $152
801078ce:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801078d3:	e9 d4 f3 ff ff       	jmp    80106cac <alltraps>

801078d8 <vector153>:
.globl vector153
vector153:
  pushl $0
801078d8:	6a 00                	push   $0x0
  pushl $153
801078da:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801078df:	e9 c8 f3 ff ff       	jmp    80106cac <alltraps>

801078e4 <vector154>:
.globl vector154
vector154:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $154
801078e6:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801078eb:	e9 bc f3 ff ff       	jmp    80106cac <alltraps>

801078f0 <vector155>:
.globl vector155
vector155:
  pushl $0
801078f0:	6a 00                	push   $0x0
  pushl $155
801078f2:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801078f7:	e9 b0 f3 ff ff       	jmp    80106cac <alltraps>

801078fc <vector156>:
.globl vector156
vector156:
  pushl $0
801078fc:	6a 00                	push   $0x0
  pushl $156
801078fe:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107903:	e9 a4 f3 ff ff       	jmp    80106cac <alltraps>

80107908 <vector157>:
.globl vector157
vector157:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $157
8010790a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010790f:	e9 98 f3 ff ff       	jmp    80106cac <alltraps>

80107914 <vector158>:
.globl vector158
vector158:
  pushl $0
80107914:	6a 00                	push   $0x0
  pushl $158
80107916:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010791b:	e9 8c f3 ff ff       	jmp    80106cac <alltraps>

80107920 <vector159>:
.globl vector159
vector159:
  pushl $0
80107920:	6a 00                	push   $0x0
  pushl $159
80107922:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107927:	e9 80 f3 ff ff       	jmp    80106cac <alltraps>

8010792c <vector160>:
.globl vector160
vector160:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $160
8010792e:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107933:	e9 74 f3 ff ff       	jmp    80106cac <alltraps>

80107938 <vector161>:
.globl vector161
vector161:
  pushl $0
80107938:	6a 00                	push   $0x0
  pushl $161
8010793a:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010793f:	e9 68 f3 ff ff       	jmp    80106cac <alltraps>

80107944 <vector162>:
.globl vector162
vector162:
  pushl $0
80107944:	6a 00                	push   $0x0
  pushl $162
80107946:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010794b:	e9 5c f3 ff ff       	jmp    80106cac <alltraps>

80107950 <vector163>:
.globl vector163
vector163:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $163
80107952:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107957:	e9 50 f3 ff ff       	jmp    80106cac <alltraps>

8010795c <vector164>:
.globl vector164
vector164:
  pushl $0
8010795c:	6a 00                	push   $0x0
  pushl $164
8010795e:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107963:	e9 44 f3 ff ff       	jmp    80106cac <alltraps>

80107968 <vector165>:
.globl vector165
vector165:
  pushl $0
80107968:	6a 00                	push   $0x0
  pushl $165
8010796a:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010796f:	e9 38 f3 ff ff       	jmp    80106cac <alltraps>

80107974 <vector166>:
.globl vector166
vector166:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $166
80107976:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010797b:	e9 2c f3 ff ff       	jmp    80106cac <alltraps>

80107980 <vector167>:
.globl vector167
vector167:
  pushl $0
80107980:	6a 00                	push   $0x0
  pushl $167
80107982:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107987:	e9 20 f3 ff ff       	jmp    80106cac <alltraps>

8010798c <vector168>:
.globl vector168
vector168:
  pushl $0
8010798c:	6a 00                	push   $0x0
  pushl $168
8010798e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107993:	e9 14 f3 ff ff       	jmp    80106cac <alltraps>

80107998 <vector169>:
.globl vector169
vector169:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $169
8010799a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010799f:	e9 08 f3 ff ff       	jmp    80106cac <alltraps>

801079a4 <vector170>:
.globl vector170
vector170:
  pushl $0
801079a4:	6a 00                	push   $0x0
  pushl $170
801079a6:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801079ab:	e9 fc f2 ff ff       	jmp    80106cac <alltraps>

801079b0 <vector171>:
.globl vector171
vector171:
  pushl $0
801079b0:	6a 00                	push   $0x0
  pushl $171
801079b2:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801079b7:	e9 f0 f2 ff ff       	jmp    80106cac <alltraps>

801079bc <vector172>:
.globl vector172
vector172:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $172
801079be:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801079c3:	e9 e4 f2 ff ff       	jmp    80106cac <alltraps>

801079c8 <vector173>:
.globl vector173
vector173:
  pushl $0
801079c8:	6a 00                	push   $0x0
  pushl $173
801079ca:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801079cf:	e9 d8 f2 ff ff       	jmp    80106cac <alltraps>

801079d4 <vector174>:
.globl vector174
vector174:
  pushl $0
801079d4:	6a 00                	push   $0x0
  pushl $174
801079d6:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801079db:	e9 cc f2 ff ff       	jmp    80106cac <alltraps>

801079e0 <vector175>:
.globl vector175
vector175:
  pushl $0
801079e0:	6a 00                	push   $0x0
  pushl $175
801079e2:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801079e7:	e9 c0 f2 ff ff       	jmp    80106cac <alltraps>

801079ec <vector176>:
.globl vector176
vector176:
  pushl $0
801079ec:	6a 00                	push   $0x0
  pushl $176
801079ee:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801079f3:	e9 b4 f2 ff ff       	jmp    80106cac <alltraps>

801079f8 <vector177>:
.globl vector177
vector177:
  pushl $0
801079f8:	6a 00                	push   $0x0
  pushl $177
801079fa:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801079ff:	e9 a8 f2 ff ff       	jmp    80106cac <alltraps>

80107a04 <vector178>:
.globl vector178
vector178:
  pushl $0
80107a04:	6a 00                	push   $0x0
  pushl $178
80107a06:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107a0b:	e9 9c f2 ff ff       	jmp    80106cac <alltraps>

80107a10 <vector179>:
.globl vector179
vector179:
  pushl $0
80107a10:	6a 00                	push   $0x0
  pushl $179
80107a12:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107a17:	e9 90 f2 ff ff       	jmp    80106cac <alltraps>

80107a1c <vector180>:
.globl vector180
vector180:
  pushl $0
80107a1c:	6a 00                	push   $0x0
  pushl $180
80107a1e:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107a23:	e9 84 f2 ff ff       	jmp    80106cac <alltraps>

80107a28 <vector181>:
.globl vector181
vector181:
  pushl $0
80107a28:	6a 00                	push   $0x0
  pushl $181
80107a2a:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107a2f:	e9 78 f2 ff ff       	jmp    80106cac <alltraps>

80107a34 <vector182>:
.globl vector182
vector182:
  pushl $0
80107a34:	6a 00                	push   $0x0
  pushl $182
80107a36:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107a3b:	e9 6c f2 ff ff       	jmp    80106cac <alltraps>

80107a40 <vector183>:
.globl vector183
vector183:
  pushl $0
80107a40:	6a 00                	push   $0x0
  pushl $183
80107a42:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107a47:	e9 60 f2 ff ff       	jmp    80106cac <alltraps>

80107a4c <vector184>:
.globl vector184
vector184:
  pushl $0
80107a4c:	6a 00                	push   $0x0
  pushl $184
80107a4e:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107a53:	e9 54 f2 ff ff       	jmp    80106cac <alltraps>

80107a58 <vector185>:
.globl vector185
vector185:
  pushl $0
80107a58:	6a 00                	push   $0x0
  pushl $185
80107a5a:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107a5f:	e9 48 f2 ff ff       	jmp    80106cac <alltraps>

80107a64 <vector186>:
.globl vector186
vector186:
  pushl $0
80107a64:	6a 00                	push   $0x0
  pushl $186
80107a66:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107a6b:	e9 3c f2 ff ff       	jmp    80106cac <alltraps>

80107a70 <vector187>:
.globl vector187
vector187:
  pushl $0
80107a70:	6a 00                	push   $0x0
  pushl $187
80107a72:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107a77:	e9 30 f2 ff ff       	jmp    80106cac <alltraps>

80107a7c <vector188>:
.globl vector188
vector188:
  pushl $0
80107a7c:	6a 00                	push   $0x0
  pushl $188
80107a7e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107a83:	e9 24 f2 ff ff       	jmp    80106cac <alltraps>

80107a88 <vector189>:
.globl vector189
vector189:
  pushl $0
80107a88:	6a 00                	push   $0x0
  pushl $189
80107a8a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107a8f:	e9 18 f2 ff ff       	jmp    80106cac <alltraps>

80107a94 <vector190>:
.globl vector190
vector190:
  pushl $0
80107a94:	6a 00                	push   $0x0
  pushl $190
80107a96:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107a9b:	e9 0c f2 ff ff       	jmp    80106cac <alltraps>

80107aa0 <vector191>:
.globl vector191
vector191:
  pushl $0
80107aa0:	6a 00                	push   $0x0
  pushl $191
80107aa2:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107aa7:	e9 00 f2 ff ff       	jmp    80106cac <alltraps>

80107aac <vector192>:
.globl vector192
vector192:
  pushl $0
80107aac:	6a 00                	push   $0x0
  pushl $192
80107aae:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107ab3:	e9 f4 f1 ff ff       	jmp    80106cac <alltraps>

80107ab8 <vector193>:
.globl vector193
vector193:
  pushl $0
80107ab8:	6a 00                	push   $0x0
  pushl $193
80107aba:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107abf:	e9 e8 f1 ff ff       	jmp    80106cac <alltraps>

80107ac4 <vector194>:
.globl vector194
vector194:
  pushl $0
80107ac4:	6a 00                	push   $0x0
  pushl $194
80107ac6:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107acb:	e9 dc f1 ff ff       	jmp    80106cac <alltraps>

80107ad0 <vector195>:
.globl vector195
vector195:
  pushl $0
80107ad0:	6a 00                	push   $0x0
  pushl $195
80107ad2:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107ad7:	e9 d0 f1 ff ff       	jmp    80106cac <alltraps>

80107adc <vector196>:
.globl vector196
vector196:
  pushl $0
80107adc:	6a 00                	push   $0x0
  pushl $196
80107ade:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107ae3:	e9 c4 f1 ff ff       	jmp    80106cac <alltraps>

80107ae8 <vector197>:
.globl vector197
vector197:
  pushl $0
80107ae8:	6a 00                	push   $0x0
  pushl $197
80107aea:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107aef:	e9 b8 f1 ff ff       	jmp    80106cac <alltraps>

80107af4 <vector198>:
.globl vector198
vector198:
  pushl $0
80107af4:	6a 00                	push   $0x0
  pushl $198
80107af6:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107afb:	e9 ac f1 ff ff       	jmp    80106cac <alltraps>

80107b00 <vector199>:
.globl vector199
vector199:
  pushl $0
80107b00:	6a 00                	push   $0x0
  pushl $199
80107b02:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107b07:	e9 a0 f1 ff ff       	jmp    80106cac <alltraps>

80107b0c <vector200>:
.globl vector200
vector200:
  pushl $0
80107b0c:	6a 00                	push   $0x0
  pushl $200
80107b0e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107b13:	e9 94 f1 ff ff       	jmp    80106cac <alltraps>

80107b18 <vector201>:
.globl vector201
vector201:
  pushl $0
80107b18:	6a 00                	push   $0x0
  pushl $201
80107b1a:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107b1f:	e9 88 f1 ff ff       	jmp    80106cac <alltraps>

80107b24 <vector202>:
.globl vector202
vector202:
  pushl $0
80107b24:	6a 00                	push   $0x0
  pushl $202
80107b26:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107b2b:	e9 7c f1 ff ff       	jmp    80106cac <alltraps>

80107b30 <vector203>:
.globl vector203
vector203:
  pushl $0
80107b30:	6a 00                	push   $0x0
  pushl $203
80107b32:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107b37:	e9 70 f1 ff ff       	jmp    80106cac <alltraps>

80107b3c <vector204>:
.globl vector204
vector204:
  pushl $0
80107b3c:	6a 00                	push   $0x0
  pushl $204
80107b3e:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107b43:	e9 64 f1 ff ff       	jmp    80106cac <alltraps>

80107b48 <vector205>:
.globl vector205
vector205:
  pushl $0
80107b48:	6a 00                	push   $0x0
  pushl $205
80107b4a:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107b4f:	e9 58 f1 ff ff       	jmp    80106cac <alltraps>

80107b54 <vector206>:
.globl vector206
vector206:
  pushl $0
80107b54:	6a 00                	push   $0x0
  pushl $206
80107b56:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107b5b:	e9 4c f1 ff ff       	jmp    80106cac <alltraps>

80107b60 <vector207>:
.globl vector207
vector207:
  pushl $0
80107b60:	6a 00                	push   $0x0
  pushl $207
80107b62:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107b67:	e9 40 f1 ff ff       	jmp    80106cac <alltraps>

80107b6c <vector208>:
.globl vector208
vector208:
  pushl $0
80107b6c:	6a 00                	push   $0x0
  pushl $208
80107b6e:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107b73:	e9 34 f1 ff ff       	jmp    80106cac <alltraps>

80107b78 <vector209>:
.globl vector209
vector209:
  pushl $0
80107b78:	6a 00                	push   $0x0
  pushl $209
80107b7a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107b7f:	e9 28 f1 ff ff       	jmp    80106cac <alltraps>

80107b84 <vector210>:
.globl vector210
vector210:
  pushl $0
80107b84:	6a 00                	push   $0x0
  pushl $210
80107b86:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107b8b:	e9 1c f1 ff ff       	jmp    80106cac <alltraps>

80107b90 <vector211>:
.globl vector211
vector211:
  pushl $0
80107b90:	6a 00                	push   $0x0
  pushl $211
80107b92:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107b97:	e9 10 f1 ff ff       	jmp    80106cac <alltraps>

80107b9c <vector212>:
.globl vector212
vector212:
  pushl $0
80107b9c:	6a 00                	push   $0x0
  pushl $212
80107b9e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107ba3:	e9 04 f1 ff ff       	jmp    80106cac <alltraps>

80107ba8 <vector213>:
.globl vector213
vector213:
  pushl $0
80107ba8:	6a 00                	push   $0x0
  pushl $213
80107baa:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107baf:	e9 f8 f0 ff ff       	jmp    80106cac <alltraps>

80107bb4 <vector214>:
.globl vector214
vector214:
  pushl $0
80107bb4:	6a 00                	push   $0x0
  pushl $214
80107bb6:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107bbb:	e9 ec f0 ff ff       	jmp    80106cac <alltraps>

80107bc0 <vector215>:
.globl vector215
vector215:
  pushl $0
80107bc0:	6a 00                	push   $0x0
  pushl $215
80107bc2:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107bc7:	e9 e0 f0 ff ff       	jmp    80106cac <alltraps>

80107bcc <vector216>:
.globl vector216
vector216:
  pushl $0
80107bcc:	6a 00                	push   $0x0
  pushl $216
80107bce:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107bd3:	e9 d4 f0 ff ff       	jmp    80106cac <alltraps>

80107bd8 <vector217>:
.globl vector217
vector217:
  pushl $0
80107bd8:	6a 00                	push   $0x0
  pushl $217
80107bda:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107bdf:	e9 c8 f0 ff ff       	jmp    80106cac <alltraps>

80107be4 <vector218>:
.globl vector218
vector218:
  pushl $0
80107be4:	6a 00                	push   $0x0
  pushl $218
80107be6:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107beb:	e9 bc f0 ff ff       	jmp    80106cac <alltraps>

80107bf0 <vector219>:
.globl vector219
vector219:
  pushl $0
80107bf0:	6a 00                	push   $0x0
  pushl $219
80107bf2:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107bf7:	e9 b0 f0 ff ff       	jmp    80106cac <alltraps>

80107bfc <vector220>:
.globl vector220
vector220:
  pushl $0
80107bfc:	6a 00                	push   $0x0
  pushl $220
80107bfe:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107c03:	e9 a4 f0 ff ff       	jmp    80106cac <alltraps>

80107c08 <vector221>:
.globl vector221
vector221:
  pushl $0
80107c08:	6a 00                	push   $0x0
  pushl $221
80107c0a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107c0f:	e9 98 f0 ff ff       	jmp    80106cac <alltraps>

80107c14 <vector222>:
.globl vector222
vector222:
  pushl $0
80107c14:	6a 00                	push   $0x0
  pushl $222
80107c16:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107c1b:	e9 8c f0 ff ff       	jmp    80106cac <alltraps>

80107c20 <vector223>:
.globl vector223
vector223:
  pushl $0
80107c20:	6a 00                	push   $0x0
  pushl $223
80107c22:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107c27:	e9 80 f0 ff ff       	jmp    80106cac <alltraps>

80107c2c <vector224>:
.globl vector224
vector224:
  pushl $0
80107c2c:	6a 00                	push   $0x0
  pushl $224
80107c2e:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107c33:	e9 74 f0 ff ff       	jmp    80106cac <alltraps>

80107c38 <vector225>:
.globl vector225
vector225:
  pushl $0
80107c38:	6a 00                	push   $0x0
  pushl $225
80107c3a:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107c3f:	e9 68 f0 ff ff       	jmp    80106cac <alltraps>

80107c44 <vector226>:
.globl vector226
vector226:
  pushl $0
80107c44:	6a 00                	push   $0x0
  pushl $226
80107c46:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107c4b:	e9 5c f0 ff ff       	jmp    80106cac <alltraps>

80107c50 <vector227>:
.globl vector227
vector227:
  pushl $0
80107c50:	6a 00                	push   $0x0
  pushl $227
80107c52:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107c57:	e9 50 f0 ff ff       	jmp    80106cac <alltraps>

80107c5c <vector228>:
.globl vector228
vector228:
  pushl $0
80107c5c:	6a 00                	push   $0x0
  pushl $228
80107c5e:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107c63:	e9 44 f0 ff ff       	jmp    80106cac <alltraps>

80107c68 <vector229>:
.globl vector229
vector229:
  pushl $0
80107c68:	6a 00                	push   $0x0
  pushl $229
80107c6a:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107c6f:	e9 38 f0 ff ff       	jmp    80106cac <alltraps>

80107c74 <vector230>:
.globl vector230
vector230:
  pushl $0
80107c74:	6a 00                	push   $0x0
  pushl $230
80107c76:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107c7b:	e9 2c f0 ff ff       	jmp    80106cac <alltraps>

80107c80 <vector231>:
.globl vector231
vector231:
  pushl $0
80107c80:	6a 00                	push   $0x0
  pushl $231
80107c82:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107c87:	e9 20 f0 ff ff       	jmp    80106cac <alltraps>

80107c8c <vector232>:
.globl vector232
vector232:
  pushl $0
80107c8c:	6a 00                	push   $0x0
  pushl $232
80107c8e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107c93:	e9 14 f0 ff ff       	jmp    80106cac <alltraps>

80107c98 <vector233>:
.globl vector233
vector233:
  pushl $0
80107c98:	6a 00                	push   $0x0
  pushl $233
80107c9a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107c9f:	e9 08 f0 ff ff       	jmp    80106cac <alltraps>

80107ca4 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ca4:	6a 00                	push   $0x0
  pushl $234
80107ca6:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107cab:	e9 fc ef ff ff       	jmp    80106cac <alltraps>

80107cb0 <vector235>:
.globl vector235
vector235:
  pushl $0
80107cb0:	6a 00                	push   $0x0
  pushl $235
80107cb2:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107cb7:	e9 f0 ef ff ff       	jmp    80106cac <alltraps>

80107cbc <vector236>:
.globl vector236
vector236:
  pushl $0
80107cbc:	6a 00                	push   $0x0
  pushl $236
80107cbe:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107cc3:	e9 e4 ef ff ff       	jmp    80106cac <alltraps>

80107cc8 <vector237>:
.globl vector237
vector237:
  pushl $0
80107cc8:	6a 00                	push   $0x0
  pushl $237
80107cca:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ccf:	e9 d8 ef ff ff       	jmp    80106cac <alltraps>

80107cd4 <vector238>:
.globl vector238
vector238:
  pushl $0
80107cd4:	6a 00                	push   $0x0
  pushl $238
80107cd6:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107cdb:	e9 cc ef ff ff       	jmp    80106cac <alltraps>

80107ce0 <vector239>:
.globl vector239
vector239:
  pushl $0
80107ce0:	6a 00                	push   $0x0
  pushl $239
80107ce2:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107ce7:	e9 c0 ef ff ff       	jmp    80106cac <alltraps>

80107cec <vector240>:
.globl vector240
vector240:
  pushl $0
80107cec:	6a 00                	push   $0x0
  pushl $240
80107cee:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107cf3:	e9 b4 ef ff ff       	jmp    80106cac <alltraps>

80107cf8 <vector241>:
.globl vector241
vector241:
  pushl $0
80107cf8:	6a 00                	push   $0x0
  pushl $241
80107cfa:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107cff:	e9 a8 ef ff ff       	jmp    80106cac <alltraps>

80107d04 <vector242>:
.globl vector242
vector242:
  pushl $0
80107d04:	6a 00                	push   $0x0
  pushl $242
80107d06:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107d0b:	e9 9c ef ff ff       	jmp    80106cac <alltraps>

80107d10 <vector243>:
.globl vector243
vector243:
  pushl $0
80107d10:	6a 00                	push   $0x0
  pushl $243
80107d12:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107d17:	e9 90 ef ff ff       	jmp    80106cac <alltraps>

80107d1c <vector244>:
.globl vector244
vector244:
  pushl $0
80107d1c:	6a 00                	push   $0x0
  pushl $244
80107d1e:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107d23:	e9 84 ef ff ff       	jmp    80106cac <alltraps>

80107d28 <vector245>:
.globl vector245
vector245:
  pushl $0
80107d28:	6a 00                	push   $0x0
  pushl $245
80107d2a:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107d2f:	e9 78 ef ff ff       	jmp    80106cac <alltraps>

80107d34 <vector246>:
.globl vector246
vector246:
  pushl $0
80107d34:	6a 00                	push   $0x0
  pushl $246
80107d36:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107d3b:	e9 6c ef ff ff       	jmp    80106cac <alltraps>

80107d40 <vector247>:
.globl vector247
vector247:
  pushl $0
80107d40:	6a 00                	push   $0x0
  pushl $247
80107d42:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107d47:	e9 60 ef ff ff       	jmp    80106cac <alltraps>

80107d4c <vector248>:
.globl vector248
vector248:
  pushl $0
80107d4c:	6a 00                	push   $0x0
  pushl $248
80107d4e:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107d53:	e9 54 ef ff ff       	jmp    80106cac <alltraps>

80107d58 <vector249>:
.globl vector249
vector249:
  pushl $0
80107d58:	6a 00                	push   $0x0
  pushl $249
80107d5a:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107d5f:	e9 48 ef ff ff       	jmp    80106cac <alltraps>

80107d64 <vector250>:
.globl vector250
vector250:
  pushl $0
80107d64:	6a 00                	push   $0x0
  pushl $250
80107d66:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107d6b:	e9 3c ef ff ff       	jmp    80106cac <alltraps>

80107d70 <vector251>:
.globl vector251
vector251:
  pushl $0
80107d70:	6a 00                	push   $0x0
  pushl $251
80107d72:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107d77:	e9 30 ef ff ff       	jmp    80106cac <alltraps>

80107d7c <vector252>:
.globl vector252
vector252:
  pushl $0
80107d7c:	6a 00                	push   $0x0
  pushl $252
80107d7e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107d83:	e9 24 ef ff ff       	jmp    80106cac <alltraps>

80107d88 <vector253>:
.globl vector253
vector253:
  pushl $0
80107d88:	6a 00                	push   $0x0
  pushl $253
80107d8a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107d8f:	e9 18 ef ff ff       	jmp    80106cac <alltraps>

80107d94 <vector254>:
.globl vector254
vector254:
  pushl $0
80107d94:	6a 00                	push   $0x0
  pushl $254
80107d96:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107d9b:	e9 0c ef ff ff       	jmp    80106cac <alltraps>

80107da0 <vector255>:
.globl vector255
vector255:
  pushl $0
80107da0:	6a 00                	push   $0x0
  pushl $255
80107da2:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107da7:	e9 00 ef ff ff       	jmp    80106cac <alltraps>

80107dac <lgdt>:
{
80107dac:	55                   	push   %ebp
80107dad:	89 e5                	mov    %esp,%ebp
80107daf:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107db2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107db5:	83 e8 01             	sub    $0x1,%eax
80107db8:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107dbc:	8b 45 08             	mov    0x8(%ebp),%eax
80107dbf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc6:	c1 e8 10             	shr    $0x10,%eax
80107dc9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107dcd:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107dd0:	0f 01 10             	lgdtl  (%eax)
}
80107dd3:	90                   	nop
80107dd4:	c9                   	leave  
80107dd5:	c3                   	ret    

80107dd6 <ltr>:
{
80107dd6:	55                   	push   %ebp
80107dd7:	89 e5                	mov    %esp,%ebp
80107dd9:	83 ec 04             	sub    $0x4,%esp
80107ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80107ddf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107de3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107de7:	0f 00 d8             	ltr    %ax
}
80107dea:	90                   	nop
80107deb:	c9                   	leave  
80107dec:	c3                   	ret    

80107ded <lcr3>:

static inline void
lcr3(uint val)
{
80107ded:	55                   	push   %ebp
80107dee:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107df0:	8b 45 08             	mov    0x8(%ebp),%eax
80107df3:	0f 22 d8             	mov    %eax,%cr3
}
80107df6:	90                   	nop
80107df7:	5d                   	pop    %ebp
80107df8:	c3                   	ret    

80107df9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107df9:	f3 0f 1e fb          	endbr32 
80107dfd:	55                   	push   %ebp
80107dfe:	89 e5                	mov    %esp,%ebp
80107e00:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107e03:	e8 8d c6 ff ff       	call   80104495 <cpuid>
80107e08:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107e0e:	05 20 58 11 80       	add    $0x80115820,%eax
80107e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e19:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e22:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e32:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e36:	83 e2 f0             	and    $0xfffffff0,%edx
80107e39:	83 ca 0a             	or     $0xa,%edx
80107e3c:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e42:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e46:	83 ca 10             	or     $0x10,%edx
80107e49:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e53:	83 e2 9f             	and    $0xffffff9f,%edx
80107e56:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e60:	83 ca 80             	or     $0xffffff80,%edx
80107e63:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e69:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e6d:	83 ca 0f             	or     $0xf,%edx
80107e70:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e76:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e7a:	83 e2 ef             	and    $0xffffffef,%edx
80107e7d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e83:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e87:	83 e2 df             	and    $0xffffffdf,%edx
80107e8a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e90:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e94:	83 ca 40             	or     $0x40,%edx
80107e97:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ea1:	83 ca 80             	or     $0xffffff80,%edx
80107ea4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eaa:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb1:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107eb8:	ff ff 
80107eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebd:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ec4:	00 00 
80107ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec9:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed3:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107eda:	83 e2 f0             	and    $0xfffffff0,%edx
80107edd:	83 ca 02             	or     $0x2,%edx
80107ee0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ef0:	83 ca 10             	or     $0x10,%edx
80107ef3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efc:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f03:	83 e2 9f             	and    $0xffffff9f,%edx
80107f06:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f16:	83 ca 80             	or     $0xffffff80,%edx
80107f19:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f22:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f29:	83 ca 0f             	or     $0xf,%edx
80107f2c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f35:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f3c:	83 e2 ef             	and    $0xffffffef,%edx
80107f3f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f48:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f4f:	83 e2 df             	and    $0xffffffdf,%edx
80107f52:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f62:	83 ca 40             	or     $0x40,%edx
80107f65:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f75:	83 ca 80             	or     $0xffffff80,%edx
80107f78:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f81:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8b:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107f92:	ff ff 
80107f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f97:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107f9e:	00 00 
80107fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa3:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fad:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fb4:	83 e2 f0             	and    $0xfffffff0,%edx
80107fb7:	83 ca 0a             	or     $0xa,%edx
80107fba:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc3:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fca:	83 ca 10             	or     $0x10,%edx
80107fcd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fdd:	83 ca 60             	or     $0x60,%edx
80107fe0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe9:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ff0:	83 ca 80             	or     $0xffffff80,%edx
80107ff3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108003:	83 ca 0f             	or     $0xf,%edx
80108006:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010800c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108016:	83 e2 ef             	and    $0xffffffef,%edx
80108019:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010801f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108022:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108029:	83 e2 df             	and    $0xffffffdf,%edx
8010802c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108035:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010803c:	83 ca 40             	or     $0x40,%edx
8010803f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108048:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010804f:	83 ca 80             	or     $0xffffff80,%edx
80108052:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805b:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108065:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010806c:	ff ff 
8010806e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108071:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108078:	00 00 
8010807a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807d:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108087:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010808e:	83 e2 f0             	and    $0xfffffff0,%edx
80108091:	83 ca 02             	or     $0x2,%edx
80108094:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010809a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080a4:	83 ca 10             	or     $0x10,%edx
801080a7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080b7:	83 ca 60             	or     $0x60,%edx
801080ba:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801080ca:	83 ca 80             	or     $0xffffff80,%edx
801080cd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801080d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080dd:	83 ca 0f             	or     $0xf,%edx
801080e0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801080f0:	83 e2 ef             	and    $0xffffffef,%edx
801080f3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801080f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108103:	83 e2 df             	and    $0xffffffdf,%edx
80108106:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010810c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108116:	83 ca 40             	or     $0x40,%edx
80108119:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010811f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108122:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108129:	83 ca 80             	or     $0xffffff80,%edx
8010812c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108135:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010813c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813f:	83 c0 70             	add    $0x70,%eax
80108142:	83 ec 08             	sub    $0x8,%esp
80108145:	6a 30                	push   $0x30
80108147:	50                   	push   %eax
80108148:	e8 5f fc ff ff       	call   80107dac <lgdt>
8010814d:	83 c4 10             	add    $0x10,%esp
}
80108150:	90                   	nop
80108151:	c9                   	leave  
80108152:	c3                   	ret    

80108153 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108153:	f3 0f 1e fb          	endbr32 
80108157:	55                   	push   %ebp
80108158:	89 e5                	mov    %esp,%ebp
8010815a:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010815d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108160:	c1 e8 16             	shr    $0x16,%eax
80108163:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010816a:	8b 45 08             	mov    0x8(%ebp),%eax
8010816d:	01 d0                	add    %edx,%eax
8010816f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108175:	8b 00                	mov    (%eax),%eax
80108177:	83 e0 01             	and    $0x1,%eax
8010817a:	85 c0                	test   %eax,%eax
8010817c:	74 14                	je     80108192 <walkpgdir+0x3f>
    //if (!alloc)
      //cprintf("page directory is good\n");
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010817e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108181:	8b 00                	mov    (%eax),%eax
80108183:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108188:	05 00 00 00 80       	add    $0x80000000,%eax
8010818d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108190:	eb 42                	jmp    801081d4 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108192:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108196:	74 0e                	je     801081a6 <walkpgdir+0x53>
80108198:	e8 cf ac ff ff       	call   80102e6c <kalloc>
8010819d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801081a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801081a4:	75 07                	jne    801081ad <walkpgdir+0x5a>
      return 0;
801081a6:	b8 00 00 00 00       	mov    $0x0,%eax
801081ab:	eb 3e                	jmp    801081eb <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801081ad:	83 ec 04             	sub    $0x4,%esp
801081b0:	68 00 10 00 00       	push   $0x1000
801081b5:	6a 00                	push   $0x0
801081b7:	ff 75 f4             	pushl  -0xc(%ebp)
801081ba:	e8 8f d5 ff ff       	call   8010574e <memset>
801081bf:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801081c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c5:	05 00 00 00 80       	add    $0x80000000,%eax
801081ca:	83 c8 07             	or     $0x7,%eax
801081cd:	89 c2                	mov    %eax,%edx
801081cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801081d2:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801081d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801081d7:	c1 e8 0c             	shr    $0xc,%eax
801081da:	25 ff 03 00 00       	and    $0x3ff,%eax
801081df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801081e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e9:	01 d0                	add    %edx,%eax
}
801081eb:	c9                   	leave  
801081ec:	c3                   	ret    

801081ed <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801081ed:	f3 0f 1e fb          	endbr32 
801081f1:	55                   	push   %ebp
801081f2:	89 e5                	mov    %esp,%ebp
801081f4:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801081f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801081fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108202:	8b 55 0c             	mov    0xc(%ebp),%edx
80108205:	8b 45 10             	mov    0x10(%ebp),%eax
80108208:	01 d0                	add    %edx,%eax
8010820a:	83 e8 01             	sub    $0x1,%eax
8010820d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108212:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108215:	83 ec 04             	sub    $0x4,%esp
80108218:	6a 01                	push   $0x1
8010821a:	ff 75 f4             	pushl  -0xc(%ebp)
8010821d:	ff 75 08             	pushl  0x8(%ebp)
80108220:	e8 2e ff ff ff       	call   80108153 <walkpgdir>
80108225:	83 c4 10             	add    $0x10,%esp
80108228:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010822b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010822f:	75 07                	jne    80108238 <mappages+0x4b>
      return -1;
80108231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108236:	eb 6a                	jmp    801082a2 <mappages+0xb5>
    if(*pte & (PTE_P | PTE_E))
80108238:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010823b:	8b 00                	mov    (%eax),%eax
8010823d:	25 01 04 00 00       	and    $0x401,%eax
80108242:	85 c0                	test   %eax,%eax
80108244:	74 0d                	je     80108253 <mappages+0x66>
      panic("p4Debug, remapping page");
80108246:	83 ec 0c             	sub    $0xc,%esp
80108249:	68 50 9d 10 80       	push   $0x80109d50
8010824e:	e8 b5 83 ff ff       	call   80100608 <panic>

    if (perm & PTE_E)
80108253:	8b 45 18             	mov    0x18(%ebp),%eax
80108256:	25 00 04 00 00       	and    $0x400,%eax
8010825b:	85 c0                	test   %eax,%eax
8010825d:	74 12                	je     80108271 <mappages+0x84>
      *pte = pa | perm | PTE_E;
8010825f:	8b 45 18             	mov    0x18(%ebp),%eax
80108262:	0b 45 14             	or     0x14(%ebp),%eax
80108265:	80 cc 04             	or     $0x4,%ah
80108268:	89 c2                	mov    %eax,%edx
8010826a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010826d:	89 10                	mov    %edx,(%eax)
8010826f:	eb 10                	jmp    80108281 <mappages+0x94>
    else
      *pte = pa | perm | PTE_P;
80108271:	8b 45 18             	mov    0x18(%ebp),%eax
80108274:	0b 45 14             	or     0x14(%ebp),%eax
80108277:	83 c8 01             	or     $0x1,%eax
8010827a:	89 c2                	mov    %eax,%edx
8010827c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010827f:	89 10                	mov    %edx,(%eax)


    if(a == last)
80108281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108284:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108287:	74 13                	je     8010829c <mappages+0xaf>
      break;
    a += PGSIZE;
80108289:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108290:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108297:	e9 79 ff ff ff       	jmp    80108215 <mappages+0x28>
      break;
8010829c:	90                   	nop
  }
  return 0;
8010829d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082a2:	c9                   	leave  
801082a3:	c3                   	ret    

801082a4 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801082a4:	f3 0f 1e fb          	endbr32 
801082a8:	55                   	push   %ebp
801082a9:	89 e5                	mov    %esp,%ebp
801082ab:	53                   	push   %ebx
801082ac:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801082af:	e8 b8 ab ff ff       	call   80102e6c <kalloc>
801082b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082bb:	75 07                	jne    801082c4 <setupkvm+0x20>
    return 0;
801082bd:	b8 00 00 00 00       	mov    $0x0,%eax
801082c2:	eb 78                	jmp    8010833c <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
801082c4:	83 ec 04             	sub    $0x4,%esp
801082c7:	68 00 10 00 00       	push   $0x1000
801082cc:	6a 00                	push   $0x0
801082ce:	ff 75 f0             	pushl  -0x10(%ebp)
801082d1:	e8 78 d4 ff ff       	call   8010574e <memset>
801082d6:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801082d9:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
801082e0:	eb 4e                	jmp    80108330 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801082e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e5:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801082e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082eb:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801082ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f1:	8b 58 08             	mov    0x8(%eax),%ebx
801082f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f7:	8b 40 04             	mov    0x4(%eax),%eax
801082fa:	29 c3                	sub    %eax,%ebx
801082fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ff:	8b 00                	mov    (%eax),%eax
80108301:	83 ec 0c             	sub    $0xc,%esp
80108304:	51                   	push   %ecx
80108305:	52                   	push   %edx
80108306:	53                   	push   %ebx
80108307:	50                   	push   %eax
80108308:	ff 75 f0             	pushl  -0x10(%ebp)
8010830b:	e8 dd fe ff ff       	call   801081ed <mappages>
80108310:	83 c4 20             	add    $0x20,%esp
80108313:	85 c0                	test   %eax,%eax
80108315:	79 15                	jns    8010832c <setupkvm+0x88>
      freevm(pgdir);
80108317:	83 ec 0c             	sub    $0xc,%esp
8010831a:	ff 75 f0             	pushl  -0x10(%ebp)
8010831d:	e8 13 05 00 00       	call   80108835 <freevm>
80108322:	83 c4 10             	add    $0x10,%esp
      return 0;
80108325:	b8 00 00 00 00       	mov    $0x0,%eax
8010832a:	eb 10                	jmp    8010833c <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010832c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108330:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
80108337:	72 a9                	jb     801082e2 <setupkvm+0x3e>
    }
  return pgdir;
80108339:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010833c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010833f:	c9                   	leave  
80108340:	c3                   	ret    

80108341 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108341:	f3 0f 1e fb          	endbr32 
80108345:	55                   	push   %ebp
80108346:	89 e5                	mov    %esp,%ebp
80108348:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010834b:	e8 54 ff ff ff       	call   801082a4 <setupkvm>
80108350:	a3 44 8f 11 80       	mov    %eax,0x80118f44
  switchkvm();
80108355:	e8 03 00 00 00       	call   8010835d <switchkvm>
}
8010835a:	90                   	nop
8010835b:	c9                   	leave  
8010835c:	c3                   	ret    

8010835d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010835d:	f3 0f 1e fb          	endbr32 
80108361:	55                   	push   %ebp
80108362:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108364:	a1 44 8f 11 80       	mov    0x80118f44,%eax
80108369:	05 00 00 00 80       	add    $0x80000000,%eax
8010836e:	50                   	push   %eax
8010836f:	e8 79 fa ff ff       	call   80107ded <lcr3>
80108374:	83 c4 04             	add    $0x4,%esp
}
80108377:	90                   	nop
80108378:	c9                   	leave  
80108379:	c3                   	ret    

8010837a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010837a:	f3 0f 1e fb          	endbr32 
8010837e:	55                   	push   %ebp
8010837f:	89 e5                	mov    %esp,%ebp
80108381:	56                   	push   %esi
80108382:	53                   	push   %ebx
80108383:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010838a:	75 0d                	jne    80108399 <switchuvm+0x1f>
    panic("switchuvm: no process");
8010838c:	83 ec 0c             	sub    $0xc,%esp
8010838f:	68 68 9d 10 80       	push   $0x80109d68
80108394:	e8 6f 82 ff ff       	call   80100608 <panic>
  if(p->kstack == 0)
80108399:	8b 45 08             	mov    0x8(%ebp),%eax
8010839c:	8b 40 08             	mov    0x8(%eax),%eax
8010839f:	85 c0                	test   %eax,%eax
801083a1:	75 0d                	jne    801083b0 <switchuvm+0x36>
    panic("switchuvm: no kstack");
801083a3:	83 ec 0c             	sub    $0xc,%esp
801083a6:	68 7e 9d 10 80       	push   $0x80109d7e
801083ab:	e8 58 82 ff ff       	call   80100608 <panic>
  if(p->pgdir == 0)
801083b0:	8b 45 08             	mov    0x8(%ebp),%eax
801083b3:	8b 40 04             	mov    0x4(%eax),%eax
801083b6:	85 c0                	test   %eax,%eax
801083b8:	75 0d                	jne    801083c7 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
801083ba:	83 ec 0c             	sub    $0xc,%esp
801083bd:	68 93 9d 10 80       	push   $0x80109d93
801083c2:	e8 41 82 ff ff       	call   80100608 <panic>

  pushcli();
801083c7:	e8 6f d2 ff ff       	call   8010563b <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801083cc:	e8 e3 c0 ff ff       	call   801044b4 <mycpu>
801083d1:	89 c3                	mov    %eax,%ebx
801083d3:	e8 dc c0 ff ff       	call   801044b4 <mycpu>
801083d8:	83 c0 08             	add    $0x8,%eax
801083db:	89 c6                	mov    %eax,%esi
801083dd:	e8 d2 c0 ff ff       	call   801044b4 <mycpu>
801083e2:	83 c0 08             	add    $0x8,%eax
801083e5:	c1 e8 10             	shr    $0x10,%eax
801083e8:	88 45 f7             	mov    %al,-0x9(%ebp)
801083eb:	e8 c4 c0 ff ff       	call   801044b4 <mycpu>
801083f0:	83 c0 08             	add    $0x8,%eax
801083f3:	c1 e8 18             	shr    $0x18,%eax
801083f6:	89 c2                	mov    %eax,%edx
801083f8:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801083ff:	67 00 
80108401:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108408:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
8010840c:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
80108412:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
80108419:	83 e0 f0             	and    $0xfffffff0,%eax
8010841c:	83 c8 09             	or     $0x9,%eax
8010841f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108425:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010842c:	83 c8 10             	or     $0x10,%eax
8010842f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108435:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010843c:	83 e0 9f             	and    $0xffffff9f,%eax
8010843f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108445:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010844c:	83 c8 80             	or     $0xffffff80,%eax
8010844f:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108455:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010845c:	83 e0 f0             	and    $0xfffffff0,%eax
8010845f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108465:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010846c:	83 e0 ef             	and    $0xffffffef,%eax
8010846f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108475:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010847c:	83 e0 df             	and    $0xffffffdf,%eax
8010847f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108485:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010848c:	83 c8 40             	or     $0x40,%eax
8010848f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108495:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010849c:	83 e0 7f             	and    $0x7f,%eax
8010849f:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801084a5:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801084ab:	e8 04 c0 ff ff       	call   801044b4 <mycpu>
801084b0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801084b7:	83 e2 ef             	and    $0xffffffef,%edx
801084ba:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801084c0:	e8 ef bf ff ff       	call   801044b4 <mycpu>
801084c5:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801084cb:	8b 45 08             	mov    0x8(%ebp),%eax
801084ce:	8b 40 08             	mov    0x8(%eax),%eax
801084d1:	89 c3                	mov    %eax,%ebx
801084d3:	e8 dc bf ff ff       	call   801044b4 <mycpu>
801084d8:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801084de:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801084e1:	e8 ce bf ff ff       	call   801044b4 <mycpu>
801084e6:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801084ec:	83 ec 0c             	sub    $0xc,%esp
801084ef:	6a 28                	push   $0x28
801084f1:	e8 e0 f8 ff ff       	call   80107dd6 <ltr>
801084f6:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801084f9:	8b 45 08             	mov    0x8(%ebp),%eax
801084fc:	8b 40 04             	mov    0x4(%eax),%eax
801084ff:	05 00 00 00 80       	add    $0x80000000,%eax
80108504:	83 ec 0c             	sub    $0xc,%esp
80108507:	50                   	push   %eax
80108508:	e8 e0 f8 ff ff       	call   80107ded <lcr3>
8010850d:	83 c4 10             	add    $0x10,%esp
  popcli();
80108510:	e8 77 d1 ff ff       	call   8010568c <popcli>
}
80108515:	90                   	nop
80108516:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108519:	5b                   	pop    %ebx
8010851a:	5e                   	pop    %esi
8010851b:	5d                   	pop    %ebp
8010851c:	c3                   	ret    

8010851d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010851d:	f3 0f 1e fb          	endbr32 
80108521:	55                   	push   %ebp
80108522:	89 e5                	mov    %esp,%ebp
80108524:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
80108527:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010852e:	76 0d                	jbe    8010853d <inituvm+0x20>
    panic("inituvm: more than a page");
80108530:	83 ec 0c             	sub    $0xc,%esp
80108533:	68 a7 9d 10 80       	push   $0x80109da7
80108538:	e8 cb 80 ff ff       	call   80100608 <panic>
  mem = kalloc();
8010853d:	e8 2a a9 ff ff       	call   80102e6c <kalloc>
80108542:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108545:	83 ec 04             	sub    $0x4,%esp
80108548:	68 00 10 00 00       	push   $0x1000
8010854d:	6a 00                	push   $0x0
8010854f:	ff 75 f4             	pushl  -0xc(%ebp)
80108552:	e8 f7 d1 ff ff       	call   8010574e <memset>
80108557:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010855a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855d:	05 00 00 00 80       	add    $0x80000000,%eax
80108562:	83 ec 0c             	sub    $0xc,%esp
80108565:	6a 06                	push   $0x6
80108567:	50                   	push   %eax
80108568:	68 00 10 00 00       	push   $0x1000
8010856d:	6a 00                	push   $0x0
8010856f:	ff 75 08             	pushl  0x8(%ebp)
80108572:	e8 76 fc ff ff       	call   801081ed <mappages>
80108577:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010857a:	83 ec 04             	sub    $0x4,%esp
8010857d:	ff 75 10             	pushl  0x10(%ebp)
80108580:	ff 75 0c             	pushl  0xc(%ebp)
80108583:	ff 75 f4             	pushl  -0xc(%ebp)
80108586:	e8 8a d2 ff ff       	call   80105815 <memmove>
8010858b:	83 c4 10             	add    $0x10,%esp
}
8010858e:	90                   	nop
8010858f:	c9                   	leave  
80108590:	c3                   	ret    

80108591 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108591:	f3 0f 1e fb          	endbr32 
80108595:	55                   	push   %ebp
80108596:	89 e5                	mov    %esp,%ebp
80108598:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010859b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010859e:	25 ff 0f 00 00       	and    $0xfff,%eax
801085a3:	85 c0                	test   %eax,%eax
801085a5:	74 0d                	je     801085b4 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
801085a7:	83 ec 0c             	sub    $0xc,%esp
801085aa:	68 c4 9d 10 80       	push   $0x80109dc4
801085af:	e8 54 80 ff ff       	call   80100608 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801085b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085bb:	e9 8f 00 00 00       	jmp    8010864f <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801085c0:	8b 55 0c             	mov    0xc(%ebp),%edx
801085c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c6:	01 d0                	add    %edx,%eax
801085c8:	83 ec 04             	sub    $0x4,%esp
801085cb:	6a 00                	push   $0x0
801085cd:	50                   	push   %eax
801085ce:	ff 75 08             	pushl  0x8(%ebp)
801085d1:	e8 7d fb ff ff       	call   80108153 <walkpgdir>
801085d6:	83 c4 10             	add    $0x10,%esp
801085d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085e0:	75 0d                	jne    801085ef <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801085e2:	83 ec 0c             	sub    $0xc,%esp
801085e5:	68 e7 9d 10 80       	push   $0x80109de7
801085ea:	e8 19 80 ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
801085ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f2:	8b 00                	mov    (%eax),%eax
801085f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801085fc:	8b 45 18             	mov    0x18(%ebp),%eax
801085ff:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108602:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108607:	77 0b                	ja     80108614 <loaduvm+0x83>
      n = sz - i;
80108609:	8b 45 18             	mov    0x18(%ebp),%eax
8010860c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010860f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108612:	eb 07                	jmp    8010861b <loaduvm+0x8a>
    else
      n = PGSIZE;
80108614:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010861b:	8b 55 14             	mov    0x14(%ebp),%edx
8010861e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108621:	01 d0                	add    %edx,%eax
80108623:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108626:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010862c:	ff 75 f0             	pushl  -0x10(%ebp)
8010862f:	50                   	push   %eax
80108630:	52                   	push   %edx
80108631:	ff 75 10             	pushl  0x10(%ebp)
80108634:	e8 4b 9a ff ff       	call   80102084 <readi>
80108639:	83 c4 10             	add    $0x10,%esp
8010863c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010863f:	74 07                	je     80108648 <loaduvm+0xb7>
      return -1;
80108641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108646:	eb 18                	jmp    80108660 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
80108648:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	3b 45 18             	cmp    0x18(%ebp),%eax
80108655:	0f 82 65 ff ff ff    	jb     801085c0 <loaduvm+0x2f>
  }
  return 0;
8010865b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108660:	c9                   	leave  
80108661:	c3                   	ret    

80108662 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108662:	f3 0f 1e fb          	endbr32 
80108666:	55                   	push   %ebp
80108667:	89 e5                	mov    %esp,%ebp
80108669:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010866c:	8b 45 10             	mov    0x10(%ebp),%eax
8010866f:	85 c0                	test   %eax,%eax
80108671:	79 0a                	jns    8010867d <allocuvm+0x1b>
    return 0;
80108673:	b8 00 00 00 00       	mov    $0x0,%eax
80108678:	e9 ec 00 00 00       	jmp    80108769 <allocuvm+0x107>
  if(newsz < oldsz)
8010867d:	8b 45 10             	mov    0x10(%ebp),%eax
80108680:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108683:	73 08                	jae    8010868d <allocuvm+0x2b>
    return oldsz;
80108685:	8b 45 0c             	mov    0xc(%ebp),%eax
80108688:	e9 dc 00 00 00       	jmp    80108769 <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
8010868d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108690:	05 ff 0f 00 00       	add    $0xfff,%eax
80108695:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010869a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010869d:	e9 b8 00 00 00       	jmp    8010875a <allocuvm+0xf8>
    mem = kalloc();
801086a2:	e8 c5 a7 ff ff       	call   80102e6c <kalloc>
801086a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801086aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086ae:	75 2e                	jne    801086de <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
801086b0:	83 ec 0c             	sub    $0xc,%esp
801086b3:	68 05 9e 10 80       	push   $0x80109e05
801086b8:	e8 5b 7d ff ff       	call   80100418 <cprintf>
801086bd:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801086c0:	83 ec 04             	sub    $0x4,%esp
801086c3:	ff 75 0c             	pushl  0xc(%ebp)
801086c6:	ff 75 10             	pushl  0x10(%ebp)
801086c9:	ff 75 08             	pushl  0x8(%ebp)
801086cc:	e8 9a 00 00 00       	call   8010876b <deallocuvm>
801086d1:	83 c4 10             	add    $0x10,%esp
      return 0;
801086d4:	b8 00 00 00 00       	mov    $0x0,%eax
801086d9:	e9 8b 00 00 00       	jmp    80108769 <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801086de:	83 ec 04             	sub    $0x4,%esp
801086e1:	68 00 10 00 00       	push   $0x1000
801086e6:	6a 00                	push   $0x0
801086e8:	ff 75 f0             	pushl  -0x10(%ebp)
801086eb:	e8 5e d0 ff ff       	call   8010574e <memset>
801086f0:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801086f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	83 ec 0c             	sub    $0xc,%esp
80108702:	6a 06                	push   $0x6
80108704:	52                   	push   %edx
80108705:	68 00 10 00 00       	push   $0x1000
8010870a:	50                   	push   %eax
8010870b:	ff 75 08             	pushl  0x8(%ebp)
8010870e:	e8 da fa ff ff       	call   801081ed <mappages>
80108713:	83 c4 20             	add    $0x20,%esp
80108716:	85 c0                	test   %eax,%eax
80108718:	79 39                	jns    80108753 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
8010871a:	83 ec 0c             	sub    $0xc,%esp
8010871d:	68 1d 9e 10 80       	push   $0x80109e1d
80108722:	e8 f1 7c ff ff       	call   80100418 <cprintf>
80108727:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
8010872a:	83 ec 04             	sub    $0x4,%esp
8010872d:	ff 75 0c             	pushl  0xc(%ebp)
80108730:	ff 75 10             	pushl  0x10(%ebp)
80108733:	ff 75 08             	pushl  0x8(%ebp)
80108736:	e8 30 00 00 00       	call   8010876b <deallocuvm>
8010873b:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
8010873e:	83 ec 0c             	sub    $0xc,%esp
80108741:	ff 75 f0             	pushl  -0x10(%ebp)
80108744:	e8 85 a6 ff ff       	call   80102dce <kfree>
80108749:	83 c4 10             	add    $0x10,%esp
      return 0;
8010874c:	b8 00 00 00 00       	mov    $0x0,%eax
80108751:	eb 16                	jmp    80108769 <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108753:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010875a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875d:	3b 45 10             	cmp    0x10(%ebp),%eax
80108760:	0f 82 3c ff ff ff    	jb     801086a2 <allocuvm+0x40>
    }
  }
  return newsz;
80108766:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108769:	c9                   	leave  
8010876a:	c3                   	ret    

8010876b <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010876b:	f3 0f 1e fb          	endbr32 
8010876f:	55                   	push   %ebp
80108770:	89 e5                	mov    %esp,%ebp
80108772:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108775:	8b 45 10             	mov    0x10(%ebp),%eax
80108778:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010877b:	72 08                	jb     80108785 <deallocuvm+0x1a>
    return oldsz;
8010877d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108780:	e9 ae 00 00 00       	jmp    80108833 <deallocuvm+0xc8>

  a = PGROUNDUP(newsz);
80108785:	8b 45 10             	mov    0x10(%ebp),%eax
80108788:	05 ff 0f 00 00       	add    $0xfff,%eax
8010878d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108792:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108795:	e9 8a 00 00 00       	jmp    80108824 <deallocuvm+0xb9>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010879a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010879d:	83 ec 04             	sub    $0x4,%esp
801087a0:	6a 00                	push   $0x0
801087a2:	50                   	push   %eax
801087a3:	ff 75 08             	pushl  0x8(%ebp)
801087a6:	e8 a8 f9 ff ff       	call   80108153 <walkpgdir>
801087ab:	83 c4 10             	add    $0x10,%esp
801087ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801087b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087b5:	75 16                	jne    801087cd <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801087b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ba:	c1 e8 16             	shr    $0x16,%eax
801087bd:	83 c0 01             	add    $0x1,%eax
801087c0:	c1 e0 16             	shl    $0x16,%eax
801087c3:	2d 00 10 00 00       	sub    $0x1000,%eax
801087c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087cb:	eb 50                	jmp    8010881d <deallocuvm+0xb2>
    else if((*pte & (PTE_P | PTE_E)) != 0){
801087cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087d0:	8b 00                	mov    (%eax),%eax
801087d2:	25 01 04 00 00       	and    $0x401,%eax
801087d7:	85 c0                	test   %eax,%eax
801087d9:	74 42                	je     8010881d <deallocuvm+0xb2>
      pa = PTE_ADDR(*pte);
801087db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087de:	8b 00                	mov    (%eax),%eax
801087e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801087e8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801087ec:	75 0d                	jne    801087fb <deallocuvm+0x90>
        panic("kfree");
801087ee:	83 ec 0c             	sub    $0xc,%esp
801087f1:	68 39 9e 10 80       	push   $0x80109e39
801087f6:	e8 0d 7e ff ff       	call   80100608 <panic>
      char *v = P2V(pa);
801087fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fe:	05 00 00 00 80       	add    $0x80000000,%eax
80108803:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108806:	83 ec 0c             	sub    $0xc,%esp
80108809:	ff 75 e8             	pushl  -0x18(%ebp)
8010880c:	e8 bd a5 ff ff       	call   80102dce <kfree>
80108811:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108814:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108817:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010881d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108827:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010882a:	0f 82 6a ff ff ff    	jb     8010879a <deallocuvm+0x2f>
    }
  }
  return newsz;
80108830:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108833:	c9                   	leave  
80108834:	c3                   	ret    

80108835 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108835:	f3 0f 1e fb          	endbr32 
80108839:	55                   	push   %ebp
8010883a:	89 e5                	mov    %esp,%ebp
8010883c:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010883f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108843:	75 0d                	jne    80108852 <freevm+0x1d>
    panic("freevm: no pgdir");
80108845:	83 ec 0c             	sub    $0xc,%esp
80108848:	68 3f 9e 10 80       	push   $0x80109e3f
8010884d:	e8 b6 7d ff ff       	call   80100608 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108852:	83 ec 04             	sub    $0x4,%esp
80108855:	6a 00                	push   $0x0
80108857:	68 00 00 00 80       	push   $0x80000000
8010885c:	ff 75 08             	pushl  0x8(%ebp)
8010885f:	e8 07 ff ff ff       	call   8010876b <deallocuvm>
80108864:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010886e:	eb 4a                	jmp    801088ba <freevm+0x85>
    if(pgdir[i] & (PTE_P | PTE_E)){
80108870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108873:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010887a:	8b 45 08             	mov    0x8(%ebp),%eax
8010887d:	01 d0                	add    %edx,%eax
8010887f:	8b 00                	mov    (%eax),%eax
80108881:	25 01 04 00 00       	and    $0x401,%eax
80108886:	85 c0                	test   %eax,%eax
80108888:	74 2c                	je     801088b6 <freevm+0x81>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010888a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108894:	8b 45 08             	mov    0x8(%ebp),%eax
80108897:	01 d0                	add    %edx,%eax
80108899:	8b 00                	mov    (%eax),%eax
8010889b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088a0:	05 00 00 00 80       	add    $0x80000000,%eax
801088a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801088a8:	83 ec 0c             	sub    $0xc,%esp
801088ab:	ff 75 f0             	pushl  -0x10(%ebp)
801088ae:	e8 1b a5 ff ff       	call   80102dce <kfree>
801088b3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801088b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801088ba:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801088c1:	76 ad                	jbe    80108870 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
801088c3:	83 ec 0c             	sub    $0xc,%esp
801088c6:	ff 75 08             	pushl  0x8(%ebp)
801088c9:	e8 00 a5 ff ff       	call   80102dce <kfree>
801088ce:	83 c4 10             	add    $0x10,%esp
}
801088d1:	90                   	nop
801088d2:	c9                   	leave  
801088d3:	c3                   	ret    

801088d4 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801088d4:	f3 0f 1e fb          	endbr32 
801088d8:	55                   	push   %ebp
801088d9:	89 e5                	mov    %esp,%ebp
801088db:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801088de:	83 ec 04             	sub    $0x4,%esp
801088e1:	6a 00                	push   $0x0
801088e3:	ff 75 0c             	pushl  0xc(%ebp)
801088e6:	ff 75 08             	pushl  0x8(%ebp)
801088e9:	e8 65 f8 ff ff       	call   80108153 <walkpgdir>
801088ee:	83 c4 10             	add    $0x10,%esp
801088f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801088f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801088f8:	75 0d                	jne    80108907 <clearpteu+0x33>
    panic("clearpteu");
801088fa:	83 ec 0c             	sub    $0xc,%esp
801088fd:	68 50 9e 10 80       	push   $0x80109e50
80108902:	e8 01 7d ff ff       	call   80100608 <panic>
  *pte &= ~PTE_U;
80108907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890a:	8b 00                	mov    (%eax),%eax
8010890c:	83 e0 fb             	and    $0xfffffffb,%eax
8010890f:	89 c2                	mov    %eax,%edx
80108911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108914:	89 10                	mov    %edx,(%eax)
}
80108916:	90                   	nop
80108917:	c9                   	leave  
80108918:	c3                   	ret    

80108919 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108919:	f3 0f 1e fb          	endbr32 
8010891d:	55                   	push   %ebp
8010891e:	89 e5                	mov    %esp,%ebp
80108920:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108923:	e8 7c f9 ff ff       	call   801082a4 <setupkvm>
80108928:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010892b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010892f:	75 0a                	jne    8010893b <copyuvm+0x22>
    return 0;
80108931:	b8 00 00 00 00       	mov    $0x0,%eax
80108936:	e9 fa 00 00 00       	jmp    80108a35 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010893b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108942:	e9 c9 00 00 00       	jmp    80108a10 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010894a:	83 ec 04             	sub    $0x4,%esp
8010894d:	6a 00                	push   $0x0
8010894f:	50                   	push   %eax
80108950:	ff 75 08             	pushl  0x8(%ebp)
80108953:	e8 fb f7 ff ff       	call   80108153 <walkpgdir>
80108958:	83 c4 10             	add    $0x10,%esp
8010895b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010895e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108962:	75 0d                	jne    80108971 <copyuvm+0x58>
      panic("p4Debug: inside copyuvm, pte should exist");
80108964:	83 ec 0c             	sub    $0xc,%esp
80108967:	68 5c 9e 10 80       	push   $0x80109e5c
8010896c:	e8 97 7c ff ff       	call   80100608 <panic>
    if(!(*pte & (PTE_P | PTE_E)))
80108971:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108974:	8b 00                	mov    (%eax),%eax
80108976:	25 01 04 00 00       	and    $0x401,%eax
8010897b:	85 c0                	test   %eax,%eax
8010897d:	75 0d                	jne    8010898c <copyuvm+0x73>
      panic("p4Debug: inside copyuvm, page not present");
8010897f:	83 ec 0c             	sub    $0xc,%esp
80108982:	68 88 9e 10 80       	push   $0x80109e88
80108987:	e8 7c 7c ff ff       	call   80100608 <panic>
    pa = PTE_ADDR(*pte);
8010898c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898f:	8b 00                	mov    (%eax),%eax
80108991:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108996:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108999:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010899c:	8b 00                	mov    (%eax),%eax
8010899e:	25 ff 0f 00 00       	and    $0xfff,%eax
801089a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801089a6:	e8 c1 a4 ff ff       	call   80102e6c <kalloc>
801089ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
801089ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801089b2:	74 6d                	je     80108a21 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801089b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089b7:	05 00 00 00 80       	add    $0x80000000,%eax
801089bc:	83 ec 04             	sub    $0x4,%esp
801089bf:	68 00 10 00 00       	push   $0x1000
801089c4:	50                   	push   %eax
801089c5:	ff 75 e0             	pushl  -0x20(%ebp)
801089c8:	e8 48 ce ff ff       	call   80105815 <memmove>
801089cd:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801089d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801089d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801089d6:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801089dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089df:	83 ec 0c             	sub    $0xc,%esp
801089e2:	52                   	push   %edx
801089e3:	51                   	push   %ecx
801089e4:	68 00 10 00 00       	push   $0x1000
801089e9:	50                   	push   %eax
801089ea:	ff 75 f0             	pushl  -0x10(%ebp)
801089ed:	e8 fb f7 ff ff       	call   801081ed <mappages>
801089f2:	83 c4 20             	add    $0x20,%esp
801089f5:	85 c0                	test   %eax,%eax
801089f7:	79 10                	jns    80108a09 <copyuvm+0xf0>
      kfree(mem);
801089f9:	83 ec 0c             	sub    $0xc,%esp
801089fc:	ff 75 e0             	pushl  -0x20(%ebp)
801089ff:	e8 ca a3 ff ff       	call   80102dce <kfree>
80108a04:	83 c4 10             	add    $0x10,%esp
      goto bad;
80108a07:	eb 19                	jmp    80108a22 <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
80108a09:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a13:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a16:	0f 82 2b ff ff ff    	jb     80108947 <copyuvm+0x2e>
    }
  }
  return d;
80108a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a1f:	eb 14                	jmp    80108a35 <copyuvm+0x11c>
      goto bad;
80108a21:	90                   	nop

bad:
  freevm(d);
80108a22:	83 ec 0c             	sub    $0xc,%esp
80108a25:	ff 75 f0             	pushl  -0x10(%ebp)
80108a28:	e8 08 fe ff ff       	call   80108835 <freevm>
80108a2d:	83 c4 10             	add    $0x10,%esp
  return 0;
80108a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a35:	c9                   	leave  
80108a36:	c3                   	ret    

80108a37 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108a37:	f3 0f 1e fb          	endbr32 
80108a3b:	55                   	push   %ebp
80108a3c:	89 e5                	mov    %esp,%ebp
80108a3e:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108a41:	83 ec 04             	sub    $0x4,%esp
80108a44:	6a 00                	push   $0x0
80108a46:	ff 75 0c             	pushl  0xc(%ebp)
80108a49:	ff 75 08             	pushl  0x8(%ebp)
80108a4c:	e8 02 f7 ff ff       	call   80108153 <walkpgdir>
80108a51:	83 c4 10             	add    $0x10,%esp
80108a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // p4Debug: Check for page's present and encrypted flags.
  if(((*pte & PTE_P) | (*pte & PTE_E)) == 0)
80108a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5a:	8b 00                	mov    (%eax),%eax
80108a5c:	25 01 04 00 00       	and    $0x401,%eax
80108a61:	85 c0                	test   %eax,%eax
80108a63:	75 07                	jne    80108a6c <uva2ka+0x35>
    return 0;
80108a65:	b8 00 00 00 00       	mov    $0x0,%eax
80108a6a:	eb 22                	jmp    80108a8e <uva2ka+0x57>
  if((*pte & PTE_U) == 0)
80108a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6f:	8b 00                	mov    (%eax),%eax
80108a71:	83 e0 04             	and    $0x4,%eax
80108a74:	85 c0                	test   %eax,%eax
80108a76:	75 07                	jne    80108a7f <uva2ka+0x48>
    return 0;
80108a78:	b8 00 00 00 00       	mov    $0x0,%eax
80108a7d:	eb 0f                	jmp    80108a8e <uva2ka+0x57>
  return (char*)P2V(PTE_ADDR(*pte));
80108a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a82:	8b 00                	mov    (%eax),%eax
80108a84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a89:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108a8e:	c9                   	leave  
80108a8f:	c3                   	ret    

80108a90 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108a90:	f3 0f 1e fb          	endbr32 
80108a94:	55                   	push   %ebp
80108a95:	89 e5                	mov    %esp,%ebp
80108a97:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108a9a:	8b 45 10             	mov    0x10(%ebp),%eax
80108a9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108aa0:	eb 7f                	jmp    80108b21 <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80108aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aa5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab0:	83 ec 08             	sub    $0x8,%esp
80108ab3:	50                   	push   %eax
80108ab4:	ff 75 08             	pushl  0x8(%ebp)
80108ab7:	e8 7b ff ff ff       	call   80108a37 <uva2ka>
80108abc:	83 c4 10             	add    $0x10,%esp
80108abf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108ac2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ac6:	75 07                	jne    80108acf <copyout+0x3f>
    {
      //p4Debug : Cannot find page in kernel space.
      return -1;
80108ac8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108acd:	eb 61                	jmp    80108b30 <copyout+0xa0>
    }
    n = PGSIZE - (va - va0);
80108acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ad2:	2b 45 0c             	sub    0xc(%ebp),%eax
80108ad5:	05 00 10 00 00       	add    $0x1000,%eax
80108ada:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108add:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae0:	3b 45 14             	cmp    0x14(%ebp),%eax
80108ae3:	76 06                	jbe    80108aeb <copyout+0x5b>
      n = len;
80108ae5:	8b 45 14             	mov    0x14(%ebp),%eax
80108ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aee:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108af1:	89 c2                	mov    %eax,%edx
80108af3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108af6:	01 d0                	add    %edx,%eax
80108af8:	83 ec 04             	sub    $0x4,%esp
80108afb:	ff 75 f0             	pushl  -0x10(%ebp)
80108afe:	ff 75 f4             	pushl  -0xc(%ebp)
80108b01:	50                   	push   %eax
80108b02:	e8 0e cd ff ff       	call   80105815 <memmove>
80108b07:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b0d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b13:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108b16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b19:	05 00 10 00 00       	add    $0x1000,%eax
80108b1e:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108b21:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108b25:	0f 85 77 ff ff ff    	jne    80108aa2 <copyout+0x12>
  }
  return 0;
80108b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b30:	c9                   	leave  
80108b31:	c3                   	ret    

80108b32 <translate_and_set>:

//This function is just like uva2ka but sets the PTE_E bit and clears PTE_P
char* translate_and_set(pde_t *pgdir, char *uva) {
80108b32:	f3 0f 1e fb          	endbr32 
80108b36:	55                   	push   %ebp
80108b37:	89 e5                	mov    %esp,%ebp
80108b39:	83 ec 18             	sub    $0x18,%esp
  cprintf("p4Debug: setting PTE_E for %p, VPN %d\n", uva, PPN(uva));
80108b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b3f:	c1 e8 0c             	shr    $0xc,%eax
80108b42:	83 ec 04             	sub    $0x4,%esp
80108b45:	50                   	push   %eax
80108b46:	ff 75 0c             	pushl  0xc(%ebp)
80108b49:	68 b4 9e 10 80       	push   $0x80109eb4
80108b4e:	e8 c5 78 ff ff       	call   80100418 <cprintf>
80108b53:	83 c4 10             	add    $0x10,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, uva, 0);
80108b56:	83 ec 04             	sub    $0x4,%esp
80108b59:	6a 00                	push   $0x0
80108b5b:	ff 75 0c             	pushl  0xc(%ebp)
80108b5e:	ff 75 08             	pushl  0x8(%ebp)
80108b61:	e8 ed f5 ff ff       	call   80108153 <walkpgdir>
80108b66:	83 c4 10             	add    $0x10,%esp
80108b69:	89 45 f4             	mov    %eax,-0xc(%ebp)

  //p4Debug: If page is not present AND it is not encrypted.
  if((*pte & PTE_P) == 0 && (*pte & PTE_E) == 0)
80108b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b6f:	8b 00                	mov    (%eax),%eax
80108b71:	83 e0 01             	and    $0x1,%eax
80108b74:	85 c0                	test   %eax,%eax
80108b76:	75 18                	jne    80108b90 <translate_and_set+0x5e>
80108b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7b:	8b 00                	mov    (%eax),%eax
80108b7d:	25 00 04 00 00       	and    $0x400,%eax
80108b82:	85 c0                	test   %eax,%eax
80108b84:	75 0a                	jne    80108b90 <translate_and_set+0x5e>
    return 0;
80108b86:	b8 00 00 00 00       	mov    $0x0,%eax
80108b8b:	e9 93 00 00 00       	jmp    80108c23 <translate_and_set+0xf1>
  //p4Debug: If page is already encrypted, i.e. PTE_E is set, return NULL as error;
  if((*pte & PTE_E)) {
80108b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b93:	8b 00                	mov    (%eax),%eax
80108b95:	25 00 04 00 00       	and    $0x400,%eax
80108b9a:	85 c0                	test   %eax,%eax
80108b9c:	74 07                	je     80108ba5 <translate_and_set+0x73>
    return 0;
80108b9e:	b8 00 00 00 00       	mov    $0x0,%eax
80108ba3:	eb 7e                	jmp    80108c23 <translate_and_set+0xf1>
  }
  // p4Debug: Check if users are allowed to use this page
  if((*pte & PTE_U) == 0)
80108ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba8:	8b 00                	mov    (%eax),%eax
80108baa:	83 e0 04             	and    $0x4,%eax
80108bad:	85 c0                	test   %eax,%eax
80108baf:	75 07                	jne    80108bb8 <translate_and_set+0x86>
    return 0;
80108bb1:	b8 00 00 00 00       	mov    $0x0,%eax
80108bb6:	eb 6b                	jmp    80108c23 <translate_and_set+0xf1>
  //p4Debug: Set Page as encrypted and not present so that we can trap(see trap.c) to decrypt page
  cprintf("p4Debug: PTE was %x and its pointer %p\n", *pte, pte);
80108bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bbb:	8b 00                	mov    (%eax),%eax
80108bbd:	83 ec 04             	sub    $0x4,%esp
80108bc0:	ff 75 f4             	pushl  -0xc(%ebp)
80108bc3:	50                   	push   %eax
80108bc4:	68 dc 9e 10 80       	push   $0x80109edc
80108bc9:	e8 4a 78 ff ff       	call   80100418 <cprintf>
80108bce:	83 c4 10             	add    $0x10,%esp
  *pte = *pte | PTE_E;
80108bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd4:	8b 00                	mov    (%eax),%eax
80108bd6:	80 cc 04             	or     $0x4,%ah
80108bd9:	89 c2                	mov    %eax,%edx
80108bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bde:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_P;
80108be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be3:	8b 00                	mov    (%eax),%eax
80108be5:	83 e0 fe             	and    $0xfffffffe,%eax
80108be8:	89 c2                	mov    %eax,%edx
80108bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bed:	89 10                	mov    %edx,(%eax)
  *pte = *pte & ~PTE_A;
80108bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf2:	8b 00                	mov    (%eax),%eax
80108bf4:	83 e0 df             	and    $0xffffffdf,%eax
80108bf7:	89 c2                	mov    %eax,%edx
80108bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfc:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: PTE is now %x\n", *pte);
80108bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c01:	8b 00                	mov    (%eax),%eax
80108c03:	83 ec 08             	sub    $0x8,%esp
80108c06:	50                   	push   %eax
80108c07:	68 04 9f 10 80       	push   $0x80109f04
80108c0c:	e8 07 78 ff ff       	call   80100418 <cprintf>
80108c11:	83 c4 10             	add    $0x10,%esp
  return (char*)P2V(PTE_ADDR(*pte));
80108c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c17:	8b 00                	mov    (%eax),%eax
80108c19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c1e:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108c23:	c9                   	leave  
80108c24:	c3                   	ret    

80108c25 <mdecrypt>:


int mdecrypt(char *virtual_addr) {
80108c25:	f3 0f 1e fb          	endbr32 
80108c29:	55                   	push   %ebp
80108c2a:	89 e5                	mov    %esp,%ebp
80108c2c:	83 ec 38             	sub    $0x38,%esp
  cprintf("p4Debug:  mdecrypt VPN %d, %p, pid %d\n", PPN(virtual_addr), virtual_addr, myproc()->pid);
80108c2f:	e8 fc b8 ff ff       	call   80104530 <myproc>
80108c34:	8b 40 10             	mov    0x10(%eax),%eax
80108c37:	8b 55 08             	mov    0x8(%ebp),%edx
80108c3a:	c1 ea 0c             	shr    $0xc,%edx
80108c3d:	50                   	push   %eax
80108c3e:	ff 75 08             	pushl  0x8(%ebp)
80108c41:	52                   	push   %edx
80108c42:	68 1c 9f 10 80       	push   $0x80109f1c
80108c47:	e8 cc 77 ff ff       	call   80100418 <cprintf>
80108c4c:	83 c4 10             	add    $0x10,%esp
  //p4Debug: virtual_addr is a virtual address in this PID's userspace.
  struct proc * p = myproc();
80108c4f:	e8 dc b8 ff ff       	call   80104530 <myproc>
80108c54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
80108c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108c5a:	8b 40 04             	mov    0x4(%eax),%eax
80108c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  //set the present bit to true and encrypt bit to false
  pte_t * pte = walkpgdir(mypd, virtual_addr, 0);
80108c60:	83 ec 04             	sub    $0x4,%esp
80108c63:	6a 00                	push   $0x0
80108c65:	ff 75 08             	pushl  0x8(%ebp)
80108c68:	ff 75 e0             	pushl  -0x20(%ebp)
80108c6b:	e8 e3 f4 ff ff       	call   80108153 <walkpgdir>
80108c70:	83 c4 10             	add    $0x10,%esp
80108c73:	89 45 dc             	mov    %eax,-0x24(%ebp)
        p->counter = 0;
      }
    }
 }
  */  
  if (!pte || *pte == 0) {
80108c76:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80108c7a:	74 09                	je     80108c85 <mdecrypt+0x60>
80108c7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108c7f:	8b 00                	mov    (%eax),%eax
80108c81:	85 c0                	test   %eax,%eax
80108c83:	75 1a                	jne    80108c9f <mdecrypt+0x7a>
    cprintf("p4Debug: walkpgdir failed\n");
80108c85:	83 ec 0c             	sub    $0xc,%esp
80108c88:	68 43 9f 10 80       	push   $0x80109f43
80108c8d:	e8 86 77 ff ff       	call   80100418 <cprintf>
80108c92:	83 c4 10             	add    $0x10,%esp
    return -1;
80108c95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c9a:	e9 55 03 00 00       	jmp    80108ff4 <mdecrypt+0x3cf>
  }
  cprintf("p4Debug: pte was %x\n", *pte);
80108c9f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108ca2:	8b 00                	mov    (%eax),%eax
80108ca4:	83 ec 08             	sub    $0x8,%esp
80108ca7:	50                   	push   %eax
80108ca8:	68 5e 9f 10 80       	push   $0x80109f5e
80108cad:	e8 66 77 ff ff       	call   80100418 <cprintf>
80108cb2:	83 c4 10             	add    $0x10,%esp
  *pte = *pte & ~PTE_E;
80108cb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cb8:	8b 00                	mov    (%eax),%eax
80108cba:	80 e4 fb             	and    $0xfb,%ah
80108cbd:	89 c2                	mov    %eax,%edx
80108cbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cc2:	89 10                	mov    %edx,(%eax)
  *pte = *pte | PTE_P;
80108cc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cc7:	8b 00                	mov    (%eax),%eax
80108cc9:	83 c8 01             	or     $0x1,%eax
80108ccc:	89 c2                	mov    %eax,%edx
80108cce:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cd1:	89 10                	mov    %edx,(%eax)
  cprintf("p4Debug: pte is %x\n", *pte);
80108cd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108cd6:	8b 00                	mov    (%eax),%eax
80108cd8:	83 ec 08             	sub    $0x8,%esp
80108cdb:	50                   	push   %eax
80108cdc:	68 73 9f 10 80       	push   $0x80109f73
80108ce1:	e8 32 77 ff ff       	call   80100418 <cprintf>
80108ce6:	83 c4 10             	add    $0x10,%esp
  char * original = uva2ka(mypd, virtual_addr) + OFFSET(virtual_addr);
80108ce9:	83 ec 08             	sub    $0x8,%esp
80108cec:	ff 75 08             	pushl  0x8(%ebp)
80108cef:	ff 75 e0             	pushl  -0x20(%ebp)
80108cf2:	e8 40 fd ff ff       	call   80108a37 <uva2ka>
80108cf7:	83 c4 10             	add    $0x10,%esp
80108cfa:	8b 55 08             	mov    0x8(%ebp),%edx
80108cfd:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
80108d03:	01 d0                	add    %edx,%eax
80108d05:	89 45 d8             	mov    %eax,-0x28(%ebp)
  cprintf("p4Debug: Original in decrypt was %p\n", original);
80108d08:	83 ec 08             	sub    $0x8,%esp
80108d0b:	ff 75 d8             	pushl  -0x28(%ebp)
80108d0e:	68 88 9f 10 80       	push   $0x80109f88
80108d13:	e8 00 77 ff ff       	call   80100418 <cprintf>
80108d18:	83 c4 10             	add    $0x10,%esp
  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80108d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d23:	89 45 08             	mov    %eax,0x8(%ebp)
  cprintf("p4Debug: mdecrypt: rounded down va is %p\n", virtual_addr);
80108d26:	83 ec 08             	sub    $0x8,%esp
80108d29:	ff 75 08             	pushl  0x8(%ebp)
80108d2c:	68 b0 9f 10 80       	push   $0x80109fb0
80108d31:	e8 e2 76 ff ff       	call   80100418 <cprintf>
80108d36:	83 c4 10             	add    $0x10,%esp

  char * kvp = uva2ka(mypd, virtual_addr);
80108d39:	83 ec 08             	sub    $0x8,%esp
80108d3c:	ff 75 08             	pushl  0x8(%ebp)
80108d3f:	ff 75 e0             	pushl  -0x20(%ebp)
80108d42:	e8 f0 fc ff ff       	call   80108a37 <uva2ka>
80108d47:	83 c4 10             	add    $0x10,%esp
80108d4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  if (!kvp || *kvp == 0) {
80108d4d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80108d51:	74 0a                	je     80108d5d <mdecrypt+0x138>
80108d53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108d56:	0f b6 00             	movzbl (%eax),%eax
80108d59:	84 c0                	test   %al,%al
80108d5b:	75 0a                	jne    80108d67 <mdecrypt+0x142>
    return -1;
80108d5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d62:	e9 8d 02 00 00       	jmp    80108ff4 <mdecrypt+0x3cf>
  }
  char * slider = virtual_addr;
80108d67:	8b 45 08             	mov    0x8(%ebp),%eax
80108d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108d6d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108d74:	eb 17                	jmp    80108d8d <mdecrypt+0x168>
    *slider = *slider ^ 0xFF;
80108d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d79:	0f b6 00             	movzbl (%eax),%eax
80108d7c:	f7 d0                	not    %eax
80108d7e:	89 c2                	mov    %eax,%edx
80108d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d83:	88 10                	mov    %dl,(%eax)
    slider++;
80108d85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  for (int offset = 0; offset < PGSIZE; offset++) {
80108d89:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108d8d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80108d94:	7e e0                	jle    80108d76 <mdecrypt+0x151>
  }
   

   if (p -> clock_size < CLOCKSIZE){
80108d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108d99:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108d9f:	83 f8 07             	cmp    $0x7,%eax
80108da2:	0f 8f 92 00 00 00    	jg     80108e3a <mdecrypt+0x215>
     p -> clock_array[p -> clock_size] =(char *) PGROUNDDOWN((int)virtual_addr);
80108da8:	8b 45 08             	mov    0x8(%ebp),%eax
80108dab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108db0:	89 c1                	mov    %eax,%ecx
80108db2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108db5:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
80108dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108dbe:	83 c2 1c             	add    $0x1c,%edx
80108dc1:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
     cprintf("VA = %x\n", virtual_addr);
80108dc5:	83 ec 08             	sub    $0x8,%esp
80108dc8:	ff 75 08             	pushl  0x8(%ebp)
80108dcb:	68 da 9f 10 80       	push   $0x80109fda
80108dd0:	e8 43 76 ff ff       	call   80100418 <cprintf>
80108dd5:	83 c4 10             	add    $0x10,%esp
     cprintf("VA inside clock = %x\n", p->clock_array[p->clock_size]);
80108dd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ddb:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
80108de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108de4:	83 c2 1c             	add    $0x1c,%edx
80108de7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108deb:	83 ec 08             	sub    $0x8,%esp
80108dee:	50                   	push   %eax
80108def:	68 e3 9f 10 80       	push   $0x80109fe3
80108df4:	e8 1f 76 ff ff       	call   80100418 <cprintf>
80108df9:	83 c4 10             	add    $0x10,%esp
     cprintf("clock size and counter = %d %d\n", p->clock_size, p -> counter);
80108dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108dff:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
80108e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e08:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108e0e:	83 ec 04             	sub    $0x4,%esp
80108e11:	52                   	push   %edx
80108e12:	50                   	push   %eax
80108e13:	68 fc 9f 10 80       	push   $0x80109ffc
80108e18:	e8 fb 75 ff ff       	call   80100418 <cprintf>
80108e1d:	83 c4 10             	add    $0x10,%esp
     p->clock_size++;
80108e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e23:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80108e29:	8d 50 01             	lea    0x1(%eax),%edx
80108e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e2f:	89 90 a0 00 00 00    	mov    %edx,0xa0(%eax)
80108e35:	e9 74 01 00 00       	jmp    80108fae <mdecrypt+0x389>
  }

  else{
    while(1){
        
        cprintf("counter referencce %d\n ----------------------------------------------------------------------",p->counter);
80108e3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e3d:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108e43:	83 ec 08             	sub    $0x8,%esp
80108e46:	50                   	push   %eax
80108e47:	68 1c a0 10 80       	push   $0x8010a01c
80108e4c:	e8 c7 75 ff ff       	call   80100418 <cprintf>
80108e51:	83 c4 10             	add    $0x10,%esp
        pte_t* pteTarget = walkpgdir(mypd, p->clock_array[p->counter%CLOCKSIZE],0);
80108e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e57:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108e5d:	99                   	cltd   
80108e5e:	c1 ea 1d             	shr    $0x1d,%edx
80108e61:	01 d0                	add    %edx,%eax
80108e63:	83 e0 07             	and    $0x7,%eax
80108e66:	29 d0                	sub    %edx,%eax
80108e68:	89 c2                	mov    %eax,%edx
80108e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e6d:	83 c2 1c             	add    $0x1c,%edx
80108e70:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108e74:	83 ec 04             	sub    $0x4,%esp
80108e77:	6a 00                	push   $0x0
80108e79:	50                   	push   %eax
80108e7a:	ff 75 e0             	pushl  -0x20(%ebp)
80108e7d:	e8 d1 f2 ff ff       	call   80108153 <walkpgdir>
80108e82:	83 c4 10             	add    $0x10,%esp
80108e85:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if((*pteTarget & PTE_A) == 0 ){
80108e88:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108e8b:	8b 00                	mov    (%eax),%eax
80108e8d:	83 e0 20             	and    $0x20,%eax
80108e90:	85 c0                	test   %eax,%eax
80108e92:	0f 85 cd 00 00 00    	jne    80108f65 <mdecrypt+0x340>
         mencrypt(p->clock_array[p->counter%CLOCKSIZE], 1); //size?
80108e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108e9b:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108ea1:	99                   	cltd   
80108ea2:	c1 ea 1d             	shr    $0x1d,%edx
80108ea5:	01 d0                	add    %edx,%eax
80108ea7:	83 e0 07             	and    $0x7,%eax
80108eaa:	29 d0                	sub    %edx,%eax
80108eac:	89 c2                	mov    %eax,%edx
80108eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108eb1:	83 c2 1c             	add    $0x1c,%edx
80108eb4:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108eb8:	83 ec 08             	sub    $0x8,%esp
80108ebb:	6a 01                	push   $0x1
80108ebd:	50                   	push   %eax
80108ebe:	e8 33 01 00 00       	call   80108ff6 <mencrypt>
80108ec3:	83 c4 10             	add    $0x10,%esp
         for(int i = p->counter%CLOCKSIZE; i < CLOCKSIZE-1; i++){
80108ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ec9:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108ecf:	99                   	cltd   
80108ed0:	c1 ea 1d             	shr    $0x1d,%edx
80108ed3:	01 d0                	add    %edx,%eax
80108ed5:	83 e0 07             	and    $0x7,%eax
80108ed8:	29 d0                	sub    %edx,%eax
80108eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108edd:	eb 21                	jmp    80108f00 <mdecrypt+0x2db>
            p->clock_array[i] = p->clock_array[i+1];
80108edf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee2:	8d 50 01             	lea    0x1(%eax),%edx
80108ee5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ee8:	83 c2 1c             	add    $0x1c,%edx
80108eeb:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80108eef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108ef2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108ef5:	83 c1 1c             	add    $0x1c,%ecx
80108ef8:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
         for(int i = p->counter%CLOCKSIZE; i < CLOCKSIZE-1; i++){
80108efc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108f00:	83 7d ec 06          	cmpl   $0x6,-0x14(%ebp)
80108f04:	7e d9                	jle    80108edf <mdecrypt+0x2ba>
        } 
         p->clock_array[CLOCKSIZE-1] =  (char*)PGROUNDDOWN((int)virtual_addr);
80108f06:	8b 45 08             	mov    0x8(%ebp),%eax
80108f09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f0e:	89 c2                	mov    %eax,%edx
80108f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f13:	89 90 98 00 00 00    	mov    %edx,0x98(%eax)
         cprintf("counter = %d\n", p->counter);
80108f19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f1c:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108f22:	83 ec 08             	sub    $0x8,%esp
80108f25:	50                   	push   %eax
80108f26:	68 7a a0 10 80       	push   $0x8010a07a
80108f2b:	e8 e8 74 ff ff       	call   80100418 <cprintf>
80108f30:	83 c4 10             	add    $0x10,%esp
         
        
         p->counter++;
80108f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f36:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108f3c:	8d 50 01             	lea    0x1(%eax),%edx
80108f3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f42:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
         if(p->counter == CLOCKSIZE){
80108f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f4b:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108f51:	83 f8 08             	cmp    $0x8,%eax
80108f54:	75 57                	jne    80108fad <mdecrypt+0x388>
         p->counter = 0;
80108f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f59:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80108f60:	00 00 00 
         }
         break;
80108f63:	eb 48                	jmp    80108fad <mdecrypt+0x388>
        }
        else {
         *pteTarget = *pteTarget & ~PTE_A;
80108f65:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f68:	8b 00                	mov    (%eax),%eax
80108f6a:	83 e0 df             	and    $0xffffffdf,%eax
80108f6d:	89 c2                	mov    %eax,%edx
80108f6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108f72:	89 10                	mov    %edx,(%eax)
        }

       p->counter++;
80108f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f77:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108f7d:	8d 50 01             	lea    0x1(%eax),%edx
80108f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f83:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
         if (p->counter == CLOCKSIZE){
80108f89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f8c:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
80108f92:	83 f8 08             	cmp    $0x8,%eax
80108f95:	0f 85 9f fe ff ff    	jne    80108e3a <mdecrypt+0x215>
         p->counter = 0;
80108f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108f9e:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
80108fa5:	00 00 00 
    while(1){
80108fa8:	e9 8d fe ff ff       	jmp    80108e3a <mdecrypt+0x215>
         break;
80108fad:	90                   	nop
     }
  }



  cprintf("---------clock----------\n");
80108fae:	83 ec 0c             	sub    $0xc,%esp
80108fb1:	68 88 a0 10 80       	push   $0x8010a088
80108fb6:	e8 5d 74 ff ff       	call   80100418 <cprintf>
80108fbb:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < CLOCKSIZE; i++)
80108fbe:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80108fc5:	eb 22                	jmp    80108fe9 <mdecrypt+0x3c4>
    cprintf("va: %x\n", p->clock_array[i]);
80108fc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108fca:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108fcd:	83 c2 1c             	add    $0x1c,%edx
80108fd0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80108fd4:	83 ec 08             	sub    $0x8,%esp
80108fd7:	50                   	push   %eax
80108fd8:	68 a2 a0 10 80       	push   $0x8010a0a2
80108fdd:	e8 36 74 ff ff       	call   80100418 <cprintf>
80108fe2:	83 c4 10             	add    $0x10,%esp
  for (int i = 0; i < CLOCKSIZE; i++)
80108fe5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80108fe9:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
80108fed:	7e d8                	jle    80108fc7 <mdecrypt+0x3a2>
  return 0;
80108fef:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108ff4:	c9                   	leave  
80108ff5:	c3                   	ret    

80108ff6 <mencrypt>:

int mencrypt(char *virtual_addr, int len) {
80108ff6:	f3 0f 1e fb          	endbr32 
80108ffa:	55                   	push   %ebp
80108ffb:	89 e5                	mov    %esp,%ebp
80108ffd:	83 ec 38             	sub    $0x38,%esp
  cprintf("p4Debug: mencrypt: %p %d\n", virtual_addr, len);
80109000:	83 ec 04             	sub    $0x4,%esp
80109003:	ff 75 0c             	pushl  0xc(%ebp)
80109006:	ff 75 08             	pushl  0x8(%ebp)
80109009:	68 aa a0 10 80       	push   $0x8010a0aa
8010900e:	e8 05 74 ff ff       	call   80100418 <cprintf>
80109013:	83 c4 10             	add    $0x10,%esp
  //the given pointer is a virtual address in this pid's userspace
  struct proc * p = myproc();
80109016:	e8 15 b5 ff ff       	call   80104530 <myproc>
8010901b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t* mypd = p->pgdir;
8010901e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109021:	8b 40 04             	mov    0x4(%eax),%eax
80109024:	89 45 e0             	mov    %eax,-0x20(%ebp)

  virtual_addr = (char *)PGROUNDDOWN((uint)virtual_addr);
80109027:	8b 45 08             	mov    0x8(%ebp),%eax
8010902a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010902f:	89 45 08             	mov    %eax,0x8(%ebp)

  //error checking first. all or nothing.
  char * slider = virtual_addr;
80109032:	8b 45 08             	mov    0x8(%ebp),%eax
80109035:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80109038:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010903f:	eb 55                	jmp    80109096 <mencrypt+0xa0>
    //check page table for each translation first
    char * kvp = uva2ka(mypd, slider);
80109041:	83 ec 08             	sub    $0x8,%esp
80109044:	ff 75 f4             	pushl  -0xc(%ebp)
80109047:	ff 75 e0             	pushl  -0x20(%ebp)
8010904a:	e8 e8 f9 ff ff       	call   80108a37 <uva2ka>
8010904f:	83 c4 10             	add    $0x10,%esp
80109052:	89 45 d0             	mov    %eax,-0x30(%ebp)
    cprintf("p4Debug: slider %p, kvp for err check is %p\n",slider, kvp);
80109055:	83 ec 04             	sub    $0x4,%esp
80109058:	ff 75 d0             	pushl  -0x30(%ebp)
8010905b:	ff 75 f4             	pushl  -0xc(%ebp)
8010905e:	68 c4 a0 10 80       	push   $0x8010a0c4
80109063:	e8 b0 73 ff ff       	call   80100418 <cprintf>
80109068:	83 c4 10             	add    $0x10,%esp
    if (!kvp) {
8010906b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
8010906f:	75 1a                	jne    8010908b <mencrypt+0x95>
      cprintf("p4Debug: mencrypt: kvp = NULL\n");
80109071:	83 ec 0c             	sub    $0xc,%esp
80109074:	68 f4 a0 10 80       	push   $0x8010a0f4
80109079:	e8 9a 73 ff ff       	call   80100418 <cprintf>
8010907e:	83 c4 10             	add    $0x10,%esp
      return -1;
80109081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109086:	e9 3f 01 00 00       	jmp    801091ca <mencrypt+0x1d4>
    }
    slider = slider + PGSIZE;
8010908b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  for (int i = 0; i < len; i++) { 
80109092:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109099:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010909c:	7c a3                	jl     80109041 <mencrypt+0x4b>
  }
 
  //encrypt stage. Have to do this before setting flag 
  //or else we'll page fault
  slider = virtual_addr;
8010909e:	8b 45 08             	mov    0x8(%ebp),%eax
801090a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < len; i++) {
801090a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801090ab:	e9 f8 00 00 00       	jmp    801091a8 <mencrypt+0x1b2>
    cprintf("p4Debug: mencryptr: VPN %d, %p\n", PPN(slider), slider);
801090b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b3:	c1 e8 0c             	shr    $0xc,%eax
801090b6:	83 ec 04             	sub    $0x4,%esp
801090b9:	ff 75 f4             	pushl  -0xc(%ebp)
801090bc:	50                   	push   %eax
801090bd:	68 14 a1 10 80       	push   $0x8010a114
801090c2:	e8 51 73 ff ff       	call   80100418 <cprintf>
801090c7:	83 c4 10             	add    $0x10,%esp
    //kvp = kernel virtual pointer
    //virtual address in kernel space that maps to the given pointer
    char * kvp = uva2ka(mypd, slider);
801090ca:	83 ec 08             	sub    $0x8,%esp
801090cd:	ff 75 f4             	pushl  -0xc(%ebp)
801090d0:	ff 75 e0             	pushl  -0x20(%ebp)
801090d3:	e8 5f f9 ff ff       	call   80108a37 <uva2ka>
801090d8:	83 c4 10             	add    $0x10,%esp
801090db:	89 45 dc             	mov    %eax,-0x24(%ebp)
    cprintf("p4Debug: kvp for encrypt stage is %p\n", kvp);
801090de:	83 ec 08             	sub    $0x8,%esp
801090e1:	ff 75 dc             	pushl  -0x24(%ebp)
801090e4:	68 34 a1 10 80       	push   $0x8010a134
801090e9:	e8 2a 73 ff ff       	call   80100418 <cprintf>
801090ee:	83 c4 10             	add    $0x10,%esp
    pte_t * mypte = walkpgdir(mypd, slider, 0);
801090f1:	83 ec 04             	sub    $0x4,%esp
801090f4:	6a 00                	push   $0x0
801090f6:	ff 75 f4             	pushl  -0xc(%ebp)
801090f9:	ff 75 e0             	pushl  -0x20(%ebp)
801090fc:	e8 52 f0 ff ff       	call   80108153 <walkpgdir>
80109101:	83 c4 10             	add    $0x10,%esp
80109104:	89 45 d8             	mov    %eax,-0x28(%ebp)
    cprintf("p4Debug: pte is %x\n", *mypte);
80109107:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010910a:	8b 00                	mov    (%eax),%eax
8010910c:	83 ec 08             	sub    $0x8,%esp
8010910f:	50                   	push   %eax
80109110:	68 73 9f 10 80       	push   $0x80109f73
80109115:	e8 fe 72 ff ff       	call   80100418 <cprintf>
8010911a:	83 c4 10             	add    $0x10,%esp
    if (*mypte & PTE_E) {
8010911d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109120:	8b 00                	mov    (%eax),%eax
80109122:	25 00 04 00 00       	and    $0x400,%eax
80109127:	85 c0                	test   %eax,%eax
80109129:	74 19                	je     80109144 <mencrypt+0x14e>
      cprintf("p4Debug: already encrypted\n");
8010912b:	83 ec 0c             	sub    $0xc,%esp
8010912e:	68 5a a1 10 80       	push   $0x8010a15a
80109133:	e8 e0 72 ff ff       	call   80100418 <cprintf>
80109138:	83 c4 10             	add    $0x10,%esp
      slider += PGSIZE;
8010913b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      continue;
80109142:	eb 60                	jmp    801091a4 <mencrypt+0x1ae>
    }
    for (int offset = 0; offset < PGSIZE; offset++) {
80109144:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
8010914b:	eb 17                	jmp    80109164 <mencrypt+0x16e>
      *slider = *slider ^ 0xFF;
8010914d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109150:	0f b6 00             	movzbl (%eax),%eax
80109153:	f7 d0                	not    %eax
80109155:	89 c2                	mov    %eax,%edx
80109157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915a:	88 10                	mov    %dl,(%eax)
      slider++;
8010915c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    for (int offset = 0; offset < PGSIZE; offset++) {
80109160:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80109164:	81 7d e8 ff 0f 00 00 	cmpl   $0xfff,-0x18(%ebp)
8010916b:	7e e0                	jle    8010914d <mencrypt+0x157>
    }
    char * kvp_translated = translate_and_set(mypd, slider-PGSIZE);
8010916d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109170:	2d 00 10 00 00       	sub    $0x1000,%eax
80109175:	83 ec 08             	sub    $0x8,%esp
80109178:	50                   	push   %eax
80109179:	ff 75 e0             	pushl  -0x20(%ebp)
8010917c:	e8 b1 f9 ff ff       	call   80108b32 <translate_and_set>
80109181:	83 c4 10             	add    $0x10,%esp
80109184:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    if (!kvp_translated) {
80109187:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010918b:	75 17                	jne    801091a4 <mencrypt+0x1ae>
      cprintf("p4Debug: translate failed!");
8010918d:	83 ec 0c             	sub    $0xc,%esp
80109190:	68 76 a1 10 80       	push   $0x8010a176
80109195:	e8 7e 72 ff ff       	call   80100418 <cprintf>
8010919a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010919d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091a2:	eb 26                	jmp    801091ca <mencrypt+0x1d4>
  for (int i = 0; i < len; i++) {
801091a4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801091a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
801091ae:	0f 8c fc fe ff ff    	jl     801090b0 <mencrypt+0xba>
    }
  }

  switchuvm(myproc());
801091b4:	e8 77 b3 ff ff       	call   80104530 <myproc>
801091b9:	83 ec 0c             	sub    $0xc,%esp
801091bc:	50                   	push   %eax
801091bd:	e8 b8 f1 ff ff       	call   8010837a <switchuvm>
801091c2:	83 c4 10             	add    $0x10,%esp
  return 0;
801091c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801091ca:	c9                   	leave  
801091cb:	c3                   	ret    

801091cc <getpgtable>:

int getpgtable(struct pt_entry* pt_entries, int num, int wsetOnly) {
801091cc:	f3 0f 1e fb          	endbr32 
801091d0:	55                   	push   %ebp
801091d1:	89 e5                	mov    %esp,%ebp
801091d3:	83 ec 28             	sub    $0x28,%esp
  cprintf("p4Debug: getpgtable: %p, %d\n", pt_entries, num);
801091d6:	83 ec 04             	sub    $0x4,%esp
801091d9:	ff 75 0c             	pushl  0xc(%ebp)
801091dc:	ff 75 08             	pushl  0x8(%ebp)
801091df:	68 91 a1 10 80       	push   $0x8010a191
801091e4:	e8 2f 72 ff ff       	call   80100418 <cprintf>
801091e9:	83 c4 10             	add    $0x10,%esp

  struct proc *curproc = myproc();
801091ec:	e8 3f b3 ff ff       	call   80104530 <myproc>
801091f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  pde_t *pgdir = curproc->pgdir;
801091f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801091f7:	8b 40 04             	mov    0x4(%eax),%eax
801091fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint uva = 0;
801091fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if (curproc->sz % PGSIZE == 0)
80109204:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109207:	8b 00                	mov    (%eax),%eax
80109209:	25 ff 0f 00 00       	and    $0xfff,%eax
8010920e:	85 c0                	test   %eax,%eax
80109210:	75 0f                	jne    80109221 <getpgtable+0x55>
    uva = curproc->sz - PGSIZE;
80109212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109215:	8b 00                	mov    (%eax),%eax
80109217:	2d 00 10 00 00       	sub    $0x1000,%eax
8010921c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010921f:	eb 0d                	jmp    8010922e <getpgtable+0x62>
  else 
    uva = PGROUNDDOWN(curproc->sz);
80109221:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109224:	8b 00                	mov    (%eax),%eax
80109226:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010922b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  int i = 0;
8010922e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  cprintf("UVA = %d\n", uva);
80109235:	83 ec 08             	sub    $0x8,%esp
80109238:	ff 75 f4             	pushl  -0xc(%ebp)
8010923b:	68 ae a1 10 80       	push   $0x8010a1ae
80109240:	e8 d3 71 ff ff       	call   80100418 <cprintf>
80109245:	83 c4 10             	add    $0x10,%esp
  for (;;uva -=PGSIZE)
  {
    
    pte_t *pte = walkpgdir(pgdir, (const void *)PGROUNDDOWN(uva), 0);
80109248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109250:	83 ec 04             	sub    $0x4,%esp
80109253:	6a 00                	push   $0x0
80109255:	50                   	push   %eax
80109256:	ff 75 e0             	pushl  -0x20(%ebp)
80109259:	e8 f5 ee ff ff       	call   80108153 <walkpgdir>
8010925e:	83 c4 10             	add    $0x10,%esp
80109261:	89 45 dc             	mov    %eax,-0x24(%ebp)
    
    if (!(*pte & PTE_U) || !(*pte & (PTE_P | PTE_E)))
80109264:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109267:	8b 00                	mov    (%eax),%eax
80109269:	83 e0 04             	and    $0x4,%eax
8010926c:	85 c0                	test   %eax,%eax
8010926e:	0f 84 1d 02 00 00    	je     80109491 <getpgtable+0x2c5>
80109274:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109277:	8b 00                	mov    (%eax),%eax
80109279:	25 01 04 00 00       	and    $0x401,%eax
8010927e:	85 c0                	test   %eax,%eax
80109280:	0f 84 0b 02 00 00    	je     80109491 <getpgtable+0x2c5>
      continue;
    int inQueue = 0;
80109286:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    for(int i = 0; i < CLOCKSIZE; i++){
8010928d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
80109294:	eb 53                	jmp    801092e9 <getpgtable+0x11d>
        if(curproc->clock_array[i] == (char*)PGROUNDDOWN(uva)){
80109296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109299:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010929c:	83 c2 1c             	add    $0x1c,%edx
8010929f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801092a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801092a6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
801092ac:	39 d0                	cmp    %edx,%eax
801092ae:	75 09                	jne    801092b9 <getpgtable+0xed>
            inQueue = 1;
801092b0:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
801092b7:	eb 2c                	jmp    801092e5 <getpgtable+0x119>
        }
        else if(i < curproc->clock_size && uva == 0 && curproc->clock_array[i] == 0){
801092b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801092bc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801092c2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
801092c5:	7d 1e                	jge    801092e5 <getpgtable+0x119>
801092c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801092cb:	75 18                	jne    801092e5 <getpgtable+0x119>
801092cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801092d0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801092d3:	83 c2 1c             	add    $0x1c,%edx
801092d6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801092da:	85 c0                	test   %eax,%eax
801092dc:	75 07                	jne    801092e5 <getpgtable+0x119>
            inQueue = 1;
801092de:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
    for(int i = 0; i < CLOCKSIZE; i++){
801092e5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
801092e9:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
801092ed:	7e a7                	jle    80109296 <getpgtable+0xca>
}
}
    cprintf("uva before: %x\n", uva);
801092ef:	83 ec 08             	sub    $0x8,%esp
801092f2:	ff 75 f4             	pushl  -0xc(%ebp)
801092f5:	68 b8 a1 10 80       	push   $0x8010a1b8
801092fa:	e8 19 71 ff ff       	call   80100418 <cprintf>
801092ff:	83 c4 10             	add    $0x10,%esp
    if (wsetOnly && !inQueue) {continue;}
80109302:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80109306:	74 0a                	je     80109312 <getpgtable+0x146>
80109308:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010930c:	0f 84 82 01 00 00    	je     80109494 <getpgtable+0x2c8>
    cprintf("uva after: %x\n", uva);
80109312:	83 ec 08             	sub    $0x8,%esp
80109315:	ff 75 f4             	pushl  -0xc(%ebp)
80109318:	68 c8 a1 10 80       	push   $0x8010a1c8
8010931d:	e8 f6 70 ff ff       	call   80100418 <cprintf>
80109322:	83 c4 10             	add    $0x10,%esp
    pt_entries[i].pdx = PDX(uva);
80109325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109328:	c1 e8 16             	shr    $0x16,%eax
8010932b:	89 c1                	mov    %eax,%ecx
8010932d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109330:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109337:	8b 45 08             	mov    0x8(%ebp),%eax
8010933a:	01 c2                	add    %eax,%edx
8010933c:	89 c8                	mov    %ecx,%eax
8010933e:	66 25 ff 03          	and    $0x3ff,%ax
80109342:	66 25 ff 03          	and    $0x3ff,%ax
80109346:	89 c1                	mov    %eax,%ecx
80109348:	0f b7 02             	movzwl (%edx),%eax
8010934b:	66 25 00 fc          	and    $0xfc00,%ax
8010934f:	09 c8                	or     %ecx,%eax
80109351:	66 89 02             	mov    %ax,(%edx)
    pt_entries[i].ptx = PTX(uva);
80109354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109357:	c1 e8 0c             	shr    $0xc,%eax
8010935a:	89 c1                	mov    %eax,%ecx
8010935c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010935f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
80109366:	8b 45 08             	mov    0x8(%ebp),%eax
80109369:	01 c2                	add    %eax,%edx
8010936b:	89 c8                	mov    %ecx,%eax
8010936d:	66 25 ff 03          	and    $0x3ff,%ax
80109371:	0f b7 c0             	movzwl %ax,%eax
80109374:	25 ff 03 00 00       	and    $0x3ff,%eax
80109379:	c1 e0 0a             	shl    $0xa,%eax
8010937c:	89 c1                	mov    %eax,%ecx
8010937e:	8b 02                	mov    (%edx),%eax
80109380:	25 ff 03 f0 ff       	and    $0xfff003ff,%eax
80109385:	09 c8                	or     %ecx,%eax
80109387:	89 02                	mov    %eax,(%edx)
    pt_entries[i].ppage = *pte >> PTXSHIFT;
80109389:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010938c:	8b 00                	mov    (%eax),%eax
8010938e:	c1 e8 0c             	shr    $0xc,%eax
80109391:	89 c2                	mov    %eax,%edx
80109393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109396:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010939d:	8b 45 08             	mov    0x8(%ebp),%eax
801093a0:	01 c8                	add    %ecx,%eax
801093a2:	81 e2 ff ff 0f 00    	and    $0xfffff,%edx
801093a8:	89 d1                	mov    %edx,%ecx
801093aa:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
801093b0:	8b 50 04             	mov    0x4(%eax),%edx
801093b3:	81 e2 00 00 f0 ff    	and    $0xfff00000,%edx
801093b9:	09 ca                	or     %ecx,%edx
801093bb:	89 50 04             	mov    %edx,0x4(%eax)
    pt_entries[i].present = *pte & PTE_P;
801093be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801093c1:	8b 08                	mov    (%eax),%ecx
801093c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
801093cd:	8b 45 08             	mov    0x8(%ebp),%eax
801093d0:	01 c2                	add    %eax,%edx
801093d2:	89 c8                	mov    %ecx,%eax
801093d4:	83 e0 01             	and    $0x1,%eax
801093d7:	83 e0 01             	and    $0x1,%eax
801093da:	c1 e0 04             	shl    $0x4,%eax
801093dd:	89 c1                	mov    %eax,%ecx
801093df:	0f b6 42 06          	movzbl 0x6(%edx),%eax
801093e3:	83 e0 ef             	and    $0xffffffef,%eax
801093e6:	09 c8                	or     %ecx,%eax
801093e8:	88 42 06             	mov    %al,0x6(%edx)
    pt_entries[i].writable = (*pte & PTE_W) > 0;
801093eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801093ee:	8b 00                	mov    (%eax),%eax
801093f0:	83 e0 02             	and    $0x2,%eax
801093f3:	89 c2                	mov    %eax,%edx
801093f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f8:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
801093ff:	8b 45 08             	mov    0x8(%ebp),%eax
80109402:	01 c8                	add    %ecx,%eax
80109404:	85 d2                	test   %edx,%edx
80109406:	0f 95 c2             	setne  %dl
80109409:	83 e2 01             	and    $0x1,%edx
8010940c:	89 d1                	mov    %edx,%ecx
8010940e:	c1 e1 05             	shl    $0x5,%ecx
80109411:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109415:	83 e2 df             	and    $0xffffffdf,%edx
80109418:	09 ca                	or     %ecx,%edx
8010941a:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].encrypted = (*pte & PTE_E) > 0;
8010941d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109420:	8b 00                	mov    (%eax),%eax
80109422:	25 00 04 00 00       	and    $0x400,%eax
80109427:	89 c2                	mov    %eax,%edx
80109429:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010942c:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109433:	8b 45 08             	mov    0x8(%ebp),%eax
80109436:	01 c8                	add    %ecx,%eax
80109438:	85 d2                	test   %edx,%edx
8010943a:	0f 95 c2             	setne  %dl
8010943d:	89 d1                	mov    %edx,%ecx
8010943f:	c1 e1 07             	shl    $0x7,%ecx
80109442:	0f b6 50 06          	movzbl 0x6(%eax),%edx
80109446:	83 e2 7f             	and    $0x7f,%edx
80109449:	09 ca                	or     %ecx,%edx
8010944b:	88 50 06             	mov    %dl,0x6(%eax)
    pt_entries[i].ref = (*pte & PTE_A) > 0;
8010944e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109451:	8b 00                	mov    (%eax),%eax
80109453:	83 e0 20             	and    $0x20,%eax
80109456:	89 c2                	mov    %eax,%edx
80109458:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010945b:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
80109462:	8b 45 08             	mov    0x8(%ebp),%eax
80109465:	01 c8                	add    %ecx,%eax
80109467:	85 d2                	test   %edx,%edx
80109469:	0f 95 c2             	setne  %dl
8010946c:	89 d1                	mov    %edx,%ecx
8010946e:	83 e1 01             	and    $0x1,%ecx
80109471:	0f b6 50 07          	movzbl 0x7(%eax),%edx
80109475:	83 e2 fe             	and    $0xfffffffe,%edx
80109478:	09 ca                	or     %ecx,%edx
8010947a:	88 50 07             	mov    %dl,0x7(%eax)
    //PT_A flag needs to be modified as per clock algo.
    i ++;
8010947d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if (uva == 0|| i == num) break;
80109481:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109485:	74 1a                	je     801094a1 <getpgtable+0x2d5>
80109487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010948a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010948d:	74 12                	je     801094a1 <getpgtable+0x2d5>
8010948f:	eb 04                	jmp    80109495 <getpgtable+0x2c9>
      continue;
80109491:	90                   	nop
80109492:	eb 01                	jmp    80109495 <getpgtable+0x2c9>
    if (wsetOnly && !inQueue) {continue;}
80109494:	90                   	nop
  for (;;uva -=PGSIZE)
80109495:	81 6d f4 00 10 00 00 	subl   $0x1000,-0xc(%ebp)
  {
8010949c:	e9 a7 fd ff ff       	jmp    80109248 <getpgtable+0x7c>

 }

  return i;
801094a1:	8b 45 f0             	mov    -0x10(%ebp),%eax

}
801094a4:	c9                   	leave  
801094a5:	c3                   	ret    

801094a6 <dump_rawphymem>:


int dump_rawphymem(uint physical_addr, char * buffer) {
801094a6:	f3 0f 1e fb          	endbr32 
801094aa:	55                   	push   %ebp
801094ab:	89 e5                	mov    %esp,%ebp
801094ad:	56                   	push   %esi
801094ae:	53                   	push   %ebx
801094af:	83 ec 10             	sub    $0x10,%esp
  *buffer = *buffer;
801094b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801094b5:	0f b6 10             	movzbl (%eax),%edx
801094b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801094bb:	88 10                	mov    %dl,(%eax)
  cprintf("p4Debug: dump_rawphymem: %p, %p\n", physical_addr, buffer);
801094bd:	83 ec 04             	sub    $0x4,%esp
801094c0:	ff 75 0c             	pushl  0xc(%ebp)
801094c3:	ff 75 08             	pushl  0x8(%ebp)
801094c6:	68 d8 a1 10 80       	push   $0x8010a1d8
801094cb:	e8 48 6f ff ff       	call   80100418 <cprintf>
801094d0:	83 c4 10             	add    $0x10,%esp
  int retval = copyout(myproc()->pgdir, (uint) buffer, (void *) PGROUNDDOWN((int)P2V(physical_addr)), PGSIZE);
801094d3:	8b 45 08             	mov    0x8(%ebp),%eax
801094d6:	05 00 00 00 80       	add    $0x80000000,%eax
801094db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801094e0:	89 c6                	mov    %eax,%esi
801094e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801094e5:	e8 46 b0 ff ff       	call   80104530 <myproc>
801094ea:	8b 40 04             	mov    0x4(%eax),%eax
801094ed:	68 00 10 00 00       	push   $0x1000
801094f2:	56                   	push   %esi
801094f3:	53                   	push   %ebx
801094f4:	50                   	push   %eax
801094f5:	e8 96 f5 ff ff       	call   80108a90 <copyout>
801094fa:	83 c4 10             	add    $0x10,%esp
801094fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (retval)
80109500:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109504:	74 07                	je     8010950d <dump_rawphymem+0x67>
    return -1;
80109506:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010950b:	eb 05                	jmp    80109512 <dump_rawphymem+0x6c>
  return 0;
8010950d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109512:	8d 65 f8             	lea    -0x8(%ebp),%esp
80109515:	5b                   	pop    %ebx
80109516:	5e                   	pop    %esi
80109517:	5d                   	pop    %ebp
80109518:	c3                   	ret    
