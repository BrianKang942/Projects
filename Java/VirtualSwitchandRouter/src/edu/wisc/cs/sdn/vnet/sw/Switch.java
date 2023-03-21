package edu.wisc.cs.sdn.vnet.sw;

import net.floodlightcontroller.packet.Ethernet;
import net.floodlightcontroller.packet.MACAddress;
import edu.wisc.cs.sdn.vnet.Device;
import edu.wisc.cs.sdn.vnet.DumpFile;
import edu.wisc.cs.sdn.vnet.Iface;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.lang.Runnable;
import java.lang.Thread;


class IfaceEntry {
	public long lastUpdate;
	public Iface iface;

	public IfaceEntry(long timestamp, Iface iface) {
        this.update(timestamp, iface);
	}

    public void update(long timestamp, Iface iface) {
        this.lastUpdate = timestamp;
		this.iface = iface;
    }
}

/**
 * @author Aaron Gember-Jacobson
 */
public class Switch extends Device implements Runnable
{	
	private ConcurrentHashMap<MACAddress, IfaceEntry> forwardMap;
	private Thread tread;

	public void run() {
		try{
			while (true) {
				for (MACAddress addr: forwardMap.keySet()) {
                    IfaceEntry entry = forwardMap.get(addr);
					long elapsed = System.currentTimeMillis() - entry.lastUpdate;
                    // Timeout - Expired
					if (elapsed >= 15000L) {
                        System.out.println("Entry Timeout: <" + addr + "," + entry.iface + ">");
						forwardMap.remove(addr);
					}
				}
				Thread.sleep(200);
			}	
		} catch (InterruptedException e) {
			e.printStackTrace(System.out);
		}
		
	}

	/**
	 * Creates a router for a specific host.
	 * @param host hostname for the router
	 */
	public Switch(String host, DumpFile logfile)
	{
		super(host,logfile);
		forwardMap = new ConcurrentHashMap<MACAddress, IfaceEntry>();
		tread = new Thread(this);
		tread.start();
	}

	/**
	 * Handle an Ethernet packet received on a specific interface.
	 * @param etherPacket the Ethernet packet that was received
	 * @param inIface the interface on which the packet was received
	 */
	public void handlePacket(Ethernet etherPacket, Iface inIface)
	{
		System.out.println("*** -> Received packet: " +
			etherPacket.toString().replace("\n", "\n\t"));
		
		MACAddress sourceMAC = etherPacket.getSourceMAC();
		MACAddress destMAC = etherPacket.getDestinationMAC();
		IfaceEntry entry = forwardMap.get(destMAC);
		
		if (entry == null) {
			System.out.print("Broadcasting to ");
			for (Iface ifa : interfaces.values()) {
				if (!inIface.equals(ifa)) {
                    System.out.print(ifa + ", ");
					sendPacket(etherPacket, ifa);
				}
			}
            System.out.println();
		} else {
			System.out.println("Sending to " + entry.iface);
			sendPacket(etherPacket, entry.iface);
		}

		if (forwardMap.containsKey(sourceMAC)) {
			System.out.println("Updating forwarding entry: <" + sourceMAC + "," + inIface + ">");
			forwardMap.get(sourceMAC).update(System.currentTimeMillis(), inIface);
		} else {
            System.out.println("Adding new forwarding entry: <" + sourceMAC + "," + inIface + ">");
			forwardMap.put(sourceMAC, new IfaceEntry(System.currentTimeMillis(), inIface));
		}
	}
}