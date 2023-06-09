package edu.wisc.cs.sdn.vnet.rt;

import edu.wisc.cs.sdn.vnet.Device;
import edu.wisc.cs.sdn.vnet.DumpFile;
import edu.wisc.cs.sdn.vnet.Iface;
import net.floodlightcontroller.packet.*;
import java.nio.*; 
import java.util.*;
import java.lang.Math; 
/**
 * @author Aaron Gember-Jacobson and Anubhavnidhi Abhashkumar
 */
public class Router extends Device
{	
	/** Routing table for the router */
	private RouteTable routeTable;
	
	/** ARP cache for the router */
	private ArpCache arpCache;
	
	/**
	 * Creates a router for a specific host.
	 * @param host hostname for the router
	 */
	public Router(String host, DumpFile logfile)
	{
		super(host,logfile);
		this.routeTable = new RouteTable();
		this.arpCache = new ArpCache();
	}
	
	/**
	 * @return routing table for the router
	 */
	public RouteTable getRouteTable()
	{ return this.routeTable; }
	
	/**
	 * Load a new routing table from a file.
	 * @param routeTableFile the name of the file containing the routing table
	 */
	public void loadRouteTable(String routeTableFile)
	{
		if (!routeTable.load(routeTableFile, this))
		{
			System.err.println("Error setting up routing table from file "
					+ routeTableFile);
			System.exit(1);
		}
		
		System.out.println("Loaded static route table");
		System.out.println("-------------------------------------------------");
		System.out.print(this.routeTable.toString());
		System.out.println("-------------------------------------------------");
	}
	
	/**
	 * Load a new ARP cache from a file.
	 * @param arpCacheFile the name of the file containing the ARP cache
	 */
	public void loadArpCache(String arpCacheFile)
	{
		if (!arpCache.load(arpCacheFile))
		{
			System.err.println("Error setting up ARP cache from file "
					+ arpCacheFile);
			System.exit(1);
		}
		
		System.out.println("Loaded static ARP cache");
		System.out.println("----------------------------------");
		System.out.print(this.arpCache.toString());
		System.out.println("----------------------------------");
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
			
		if (etherPacket.getEtherType() != Ethernet.TYPE_IPv4) {
			return;
		}
		else {
		//cast to IPv4 to use functions
        IPv4 payload = (IPv4)etherPacket.getPayload();
		
			//CALCULATE THE CHECKSUM
			short checksum = payload.getChecksum();

			byte[] data = payload.serialize(); //using serialize to calculate checksum
			ByteBuffer bytecalc = ByteBuffer.wrap(data);
			bytecalc.putShort(10,(short) 0x0000);
			int mycalc = 0;

			for (int i = 0; i < payload.getHeaderLength() * 2; ++i) {
				mycalc += bytecalc.getShort() & 0xffff;
			}

			mycalc = ((mycalc >> 16) & 0xffff) + (mycalc & 0xffff);
			short checksumCalculation = (short)(~mycalc & 0xffff);

			if(checksum != checksumCalculation) {
				return;
			}
			//DECREMENT 
            payload.setTtl((byte)(payload.getTtl()-1));
			
            if (payload.getTtl() == 0) {
                return;	
			}
			//reset the checksum!
			payload.resetChecksum();
			Ethernet etherpack = (Ethernet)etherPacket.setPayload(payload);

			//determine whether the packet is destined for one of the router’s interfaces
			for (Iface face : interfaces.values()) {
           		if (face.getIpAddress() == payload.getDestinationAddress()) {
                return;
				}
			}
			//Sending the packets
			RouteEntry routeLook = routeTable.lookup(payload.getDestinationAddress());

			if (routeLook != null) {
                ArpEntry arpLook = null;
                if (routeLook.getGatewayAddress() != 0) {
                    arpLook = arpCache.lookup(routeLook.getDestinationAddress());
				}
			else {
				arpLook = arpCache.lookup(payload.getDestinationAddress());
			}
				if (arpLook != null) {
					MACAddress destination = arpLook.getMac();
					MACAddress starting = routeLook.getInterface().getMacAddress();
					etherpack = etherpack.setDestinationMACAddress(destination.toBytes());
					etherpack = etherpack.setSourceMACAddress(starting.toBytes());
				}
				//sending packets
				sendPacket(etherpack, routeLook.getInterface());
			}
		}
	}
}
