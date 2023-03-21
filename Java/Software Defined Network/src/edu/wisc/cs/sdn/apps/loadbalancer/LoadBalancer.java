package edu.wisc.cs.sdn.apps.loadbalancer;

import java.util.*;


import org.openflow.protocol.OFMessage;
import org.openflow.protocol.OFPacketIn;
import org.openflow.protocol.OFType;
import org.openflow.protocol.OFMatch;
import org.openflow.protocol.OFPort;
import org.openflow.protocol.OFOXMFieldType;
import org.openflow.protocol.action.OFActionSetField;
import org.openflow.protocol.action.OFAction;
import org.openflow.protocol.action.OFActionOutput;
import org.openflow.protocol.instruction.OFInstruction;
import org.openflow.protocol.instruction.OFInstructionApplyActions;
import org.openflow.protocol.instruction.OFInstructionGotoTable;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import edu.wisc.cs.sdn.apps.util.ArpServer;
import edu.wisc.cs.sdn.apps.l3routing.L3Routing;
import edu.wisc.cs.sdn.apps.util.SwitchCommands;

import net.floodlightcontroller.core.FloodlightContext;
import net.floodlightcontroller.core.IFloodlightProviderService;
import net.floodlightcontroller.core.IOFMessageListener;
import net.floodlightcontroller.core.IOFSwitch.PortChangeType;
import net.floodlightcontroller.core.IOFSwitch;
import net.floodlightcontroller.core.IOFSwitchListener;
import net.floodlightcontroller.core.ImmutablePort;
import net.floodlightcontroller.core.module.FloodlightModuleContext;
import net.floodlightcontroller.core.module.FloodlightModuleException;
import net.floodlightcontroller.core.module.IFloodlightModule;
import net.floodlightcontroller.core.module.IFloodlightService;
import net.floodlightcontroller.devicemanager.IDevice;
import net.floodlightcontroller.devicemanager.IDeviceService;
import net.floodlightcontroller.devicemanager.internal.DeviceManagerImpl;
import net.floodlightcontroller.packet.Ethernet;
import net.floodlightcontroller.util.MACAddress;
import net.floodlightcontroller.packet.TCP;
import net.floodlightcontroller.packet.IPv4;
import net.floodlightcontroller.packet.ARP;

public class LoadBalancer implements IFloodlightModule, IOFSwitchListener,
		IOFMessageListener
{
	public static final String MODULE_NAME = LoadBalancer.class.getSimpleName();
	
	private static final byte TCP_FLAG_SYN = 0x02;
	
	private static final short IDLE_TIMEOUT = 20;
	
	// Interface to the logging system
    private static Logger log = LoggerFactory.getLogger(MODULE_NAME);
    
    // Interface to Floodlight core for interacting with connected switches
    private IFloodlightProviderService floodlightProv;
    
    // Interface to device manager service
    private IDeviceService deviceProv;
    
    // Switch table in which rules should be installed
    private byte table;
    
    // Set of virtual IPs and the load balancer instances they correspond with
    private Map<Integer,LoadBalancerInstance> instances;

    /**
     * Loads dependencies and initializes data structures.
     */
	@Override
	public void init(FloodlightModuleContext context)
			throws FloodlightModuleException 
	{
		log.info(String.format("Initializing %s...", MODULE_NAME));
		
		// Obtain table number from config
		Map<String,String> config = context.getConfigParams(this);
        this.table = Byte.parseByte(config.get("table"));
        
        // Create instances from config
        this.instances = new HashMap<Integer,LoadBalancerInstance>();
        String[] instanceConfigs = config.get("instances").split(";");
        for (String instanceConfig : instanceConfigs)
        {
        	String[] configItems = instanceConfig.split(" ");
        	if (configItems.length != 3)
        	{ 
        		log.error("Ignoring bad instance config: " + instanceConfig);
        		continue;
        	}
        	LoadBalancerInstance instance = new LoadBalancerInstance(
        			configItems[0], configItems[1], configItems[2].split(","));
            this.instances.put(instance.getVirtualIP(), instance);
            log.info("Added load balancer instance: " + instance);
        }
        
		this.floodlightProv = context.getServiceImpl(
				IFloodlightProviderService.class);
        this.deviceProv = context.getServiceImpl(IDeviceService.class);
        
        /*********************************************************************/
        /*             */
        
        /*********************************************************************/
	}

	/**
     * Subscribes to events and performs other startup tasks.
     */
	@Override
	public void startUp(FloodlightModuleContext context)
			throws FloodlightModuleException 
	{
		log.info(String.format("Starting %s...", MODULE_NAME));
		this.floodlightProv.addOFSwitchListener(this);
		this.floodlightProv.addOFMessageListener(OFType.PACKET_IN, this);
		
		/*********************************************************************/
		/*                         */
		
		/*********************************************************************/
	}
	
	/**
     * Event handler called when a switch joins the network.
     * @param DPID for the switch
     */
	@Override
	public void switchAdded(long switchId) 
	{
		IOFSwitch sw = this.floodlightProv.getSwitch(switchId);
		log.info(String.format("Switch s%d added", switchId));
		
		/*********************************************************************/
		/*                                     */
		/*       (1) packets from new connections to each virtual load       */
		/*       balancer IP to the controller                               */
		/*       (2) ARP packets to the controller, and                      */
		/*       (3) all other packets to the next rule table in the switch  */
		
		/*********************************************************************/
		//create a set out of the key elements contained in the hash map
		for (Integer virtualLoad : instances.keySet()) {
			OFMatch newOF = new OFMatch();
			//has to be in this order, must set type before destination in order to reach next switch in path
			//we set the datalayertype to ipv4 first, then we do it for arp
			newOF.setDataLayerType(OFMatch.ETH_TYPE_IPV4);
			newOF.setNetworkProtocol(OFMatch.IP_PROTO_TCP);
			newOF.setNetworkDestination(virtualLoad);

			OFAction newOFAction = new OFActionOutput(OFPort.OFPP_CONTROLLER);
			OFInstruction actionRoute = new OFInstructionApplyActions(Arrays.asList(newOFAction));
			//Priority + 1 because sending new connection and ARP packets to controller
			SwitchCommands.installRule(sw, this.table, (short)(SwitchCommands.DEFAULT_PRIORITY+1), newOF, Arrays.asList(actionRoute));
			//Same thing but ARP data layer type
			newOF = new OFMatch();
			newOF.setDataLayerType(OFMatch.ETH_TYPE_ARP);
			newOF.setNetworkDestination(virtualLoad);

			newOFAction = new OFActionOutput(OFPort.OFPP_CONTROLLER);
			actionRoute = new OFInstructionApplyActions(Arrays.asList(newOFAction));
			//Priority + 1 because sending new connection and ARP packets to controller
			SwitchCommands.installRule(sw, this.table, (short)(SwitchCommands.DEFAULT_PRIORITY+1), newOF, Arrays.asList(actionRoute));
		}

		OFMatch newOF = new OFMatch();
		OFInstruction actionRoute = new OFInstructionGotoTable(L3Routing.table);
		SwitchCommands.installRule(sw, this.table, SwitchCommands.DEFAULT_PRIORITY, newOF, Arrays.asList(actionRoute));	

	}
	
	/**
	 * Handle incoming packets sent from switches.
	 * @param sw switch on which the packet was received
	 * @param msg message from the switch
	 * @param cntx the Floodlight context in which the message should be handled
	 * @return indication whether another module should also process the packet
	 */
	@Override
	public net.floodlightcontroller.core.IListener.Command receive(
			IOFSwitch sw, OFMessage msg, FloodlightContext cntx) 
	{
		// We're only interested in packet-in messages
		if (msg.getType() != OFType.PACKET_IN)
		{ return Command.CONTINUE; }
		OFPacketIn pktIn = (OFPacketIn)msg;
		
		// Handle the packet
		Ethernet ethPkt = new Ethernet();
		ethPkt.deserialize(pktIn.getPacketData(), 0,
				pktIn.getPacketData().length);
		
		/*********************************************************************/
		/**/
		/*       SYNs sent to a virtual IP, select a host and install        */
		/*       connection-specific rules to rewrite IP and MAC addresses;  */
		/*       ignore all other packets                                    */
		
		/*********************************************************************/

		//type ARP
		if (ethPkt.getEtherType() == Ethernet.TYPE_ARP) {
			ARP arpPacket = (ARP) ethPkt.getPayload();
			int virtualIP = IPv4.toIPv4Address(arpPacket.getTargetProtocolAddress());
			if(this.instances.containsKey(virtualIP)){
				Ethernet etherVal = new Ethernet();
				ARP arpVal = new ARP();
				byte[] macAdd = this.instances.get(virtualIP).getVirtualMAC();
				//Very similar to project 3, actually pretty much the same 
				//Install connection-specific rules for each new connection to a virtual IP 
				//Create arp reply package by referring to net.floodlightcontroller.packet package
				arpVal.setOpCode(ARP.OP_REPLY);
				//Protocol
				arpVal.setProtocolAddressLength(arpPacket.getProtocolAddressLength());
				arpVal.setSenderProtocolAddress(virtualIP);
				
				arpVal.setProtocolType(arpPacket.getProtocolType());
				arpVal.setTargetProtocolAddress(arpPacket.getSenderProtocolAddress());
				//hardware
				arpVal.setHardwareAddressLength(arpPacket.getHardwareAddressLength());	
				arpVal.setSenderHardwareAddress(macAdd);
				
				arpVal.setHardwareType(arpPacket.getHardwareType());
				arpVal.setTargetHardwareAddress(arpPacket.getSenderHardwareAddress());
				
				etherVal.setEtherType(Ethernet.TYPE_ARP);
				etherVal.setDestinationMACAddress(ethPkt.getSourceMACAddress());
				etherVal.setSourceMACAddress(macAdd);
				
				etherVal.setPayload(arpVal);
				//we have constructed the ARP reply package and now can send it through sendPacket
				SwitchCommands.sendPacket(sw, (short)pktIn.getInPort(), etherVal);	

			}
		}
		//type IPv4
		if (ethPkt.getEtherType() == Ethernet.TYPE_IPv4) { 
			IPv4 ipPacket = (IPv4) ethPkt.getPayload();
			if (ipPacket.getProtocol() == IPv4.PROTOCOL_TCP){
				TCP tcpPacket = (TCP) ipPacket.getPayload();
				if (tcpPacket.getFlags() == TCP_FLAG_SYN){
					int destinationIP = ipPacket.getDestinationAddress();
					int nextIP = this.instances.get(destinationIP).getNextHostIP();

					OFMatch ofMatchVal = new OFMatch();
					ofMatchVal.setDataLayerType(Ethernet.TYPE_IPv4);
					ofMatchVal.setNetworkSource(ipPacket.getSourceAddress());
					ofMatchVal.setNetworkDestination(destinationIP);
					ofMatchVal.setNetworkProtocol(OFMatch.IP_PROTO_TCP);
					ofMatchVal.setTransportSource(OFMatch.IP_PROTO_TCP, tcpPacket.getSourcePort());
					ofMatchVal.setTransportDestination(OFMatch.IP_PROTO_TCP, tcpPacket.getDestinationPort());
					//rewriting destination ip and MAC, hence the rule includes an OFInstructionApplyActions
					OFAction ipAdd = new OFActionSetField(OFOXMFieldType.IPV4_DST, nextIP);
					OFAction macVal = new OFActionSetField(OFOXMFieldType.ETH_DST, this.getHostMACAddress(nextIP));
					OFInstruction actionRoute =  new OFInstructionApplyActions(Arrays.asList(ipAdd, macVal));
					//rule should include an OFInstructionGotoTable whose table number is the value
					OFInstruction actionRouteL3 = new OFInstructionGotoTable(L3Routing.table);

					SwitchCommands.installRule(sw, table, (short)(SwitchCommands.DEFAULT_PRIORITY+2), ofMatchVal, Arrays.asList(actionRoute, actionRouteL3), SwitchCommands.NO_TIMEOUT, IDLE_TIMEOUT);

					ofMatchVal = new OFMatch();
					ofMatchVal.setDataLayerType(Ethernet.TYPE_IPv4);
					ofMatchVal.setNetworkSource(nextIP);
					ofMatchVal.setNetworkDestination(ipPacket.getSourceAddress());
					ofMatchVal.setNetworkProtocol(OFMatch.IP_PROTO_TCP);
					ofMatchVal.setTransportSource(OFMatch.IP_PROTO_TCP, tcpPacket.getDestinationPort());
					ofMatchVal.setTransportDestination(OFMatch.IP_PROTO_TCP, tcpPacket.getSourcePort());

					ipAdd = new OFActionSetField(OFOXMFieldType.IPV4_SRC, destinationIP);
					macVal = new OFActionSetField(OFOXMFieldType.ETH_SRC, this.instances.get(destinationIP).getVirtualMAC());
					actionRoute =  new OFInstructionApplyActions(Arrays.asList(ipAdd, macVal));

					SwitchCommands.installRule(sw, table, (short)(SwitchCommands.DEFAULT_PRIORITY+2), ofMatchVal, Arrays.asList(actionRoute, actionRouteL3), SwitchCommands.NO_TIMEOUT, IDLE_TIMEOUT);

				}
			}
		}
		

		// We don't care about other packets
		return Command.CONTINUE;
	}
	
	/**
	 * Returns the MAC address for a host, given the host's IP address.
	 * @param hostIPAddress the host's IP address
	 * @return the hosts's MAC address, null if unknown
	 */
	private byte[] getHostMACAddress(int hostIPAddress)
	{
		Iterator<? extends IDevice> iterator = this.deviceProv.queryDevices(
				null, null, hostIPAddress, null, null);
		if (!iterator.hasNext())
		{ return null; }
		IDevice device = iterator.next();
		return MACAddress.valueOf(device.getMACAddress()).toBytes();
	}

	/**
	 * Event handler called when a switch leaves the network.
	 * @param DPID for the switch
	 */
	@Override
	public void switchRemoved(long switchId) 
	{ /* Nothing we need to do, since the switch is no longer active */ }

	/**
	 * Event handler called when the controller becomes the master for a switch.
	 * @param DPID for the switch
	 */
	@Override
	public void switchActivated(long switchId)
	{ /* Nothing we need to do, since we're not switching controller roles */ }

	/**
	 * Event handler called when a port on a switch goes up or down, or is
	 * added or removed.
	 * @param DPID for the switch
	 * @param port the port on the switch whose status changed
	 * @param type the type of status change (up, down, add, remove)
	 */
	@Override
	public void switchPortChanged(long switchId, ImmutablePort port,
			PortChangeType type) 
	{ /* Nothing we need to do, since load balancer rules are port-agnostic */}

	/**
	 * Event handler called when some attribute of a switch changes.
	 * @param DPID for the switch
	 */
	@Override
	public void switchChanged(long switchId) 
	{ /* Nothing we need to do */ }
	
    /**
     * Tell the module system which services we provide.
     */
	@Override
	public Collection<Class<? extends IFloodlightService>> getModuleServices() 
	{ return null; }

	/**
     * Tell the module system which services we implement.
     */
	@Override
	public Map<Class<? extends IFloodlightService>, IFloodlightService> 
			getServiceImpls() 
	{ return null; }

	/**
     * Tell the module system which modules we depend on.
     */
	@Override
	public Collection<Class<? extends IFloodlightService>> 
			getModuleDependencies() 
	{
		Collection<Class<? extends IFloodlightService >> floodlightService =
	            new ArrayList<Class<? extends IFloodlightService>>();
        floodlightService.add(IFloodlightProviderService.class);
        floodlightService.add(IDeviceService.class);
        return floodlightService;
	}

	/**
	 * Gets a name for this module.
	 * @return name for this module
	 */
	@Override
	public String getName() 
	{ return MODULE_NAME; }

	/**
	 * Check if events must be passed to another module before this module is
	 * notified of the event.
	 */
	@Override
	public boolean isCallbackOrderingPrereq(OFType type, String name) 
	{
		return (OFType.PACKET_IN == type 
				&& (name.equals(ArpServer.MODULE_NAME) 
					|| name.equals(DeviceManagerImpl.MODULE_NAME))); 
	}

	/**
	 * Check if events must be passed to another module after this module has
	 * been notified of the event.
	 */
	@Override
	public boolean isCallbackOrderingPostreq(OFType type, String name) 
	{ return false; }
}
